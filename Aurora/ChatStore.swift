import Foundation
import FoundationModels
import Observation

@MainActor
@Observable
final class ChatStore {
    var conversations: [ChatConversation] = [] {
        didSet { recomputeVisibleConversations() }
    }
    var visibleConversations: [ChatConversation] = []
    var selectedConversationID: UUID?
    var draft = ""
    var searchQuery = "" {
        didSet { recomputeVisibleConversations() }
    }
    var isGenerating = false
    var availabilityState: ModelAvailabilityState = .unavailable
    var archiveErrorMessage: String?
    var isShowingArchiveError: Bool {
        get { archiveErrorMessage != nil }
        set {
            if !newValue {
                archiveErrorMessage = nil
            }
        }
    }

    @ObservationIgnored private let model = SystemLanguageModel.default
    @ObservationIgnored private var session: LanguageModelSession?
    @ObservationIgnored private var sessionConversationID: UUID?
    @ObservationIgnored private var generationTask: Task<Void, Never>?

    var selectedConversation: ChatConversation? {
        guard let selectedConversationID else { return nil }
        return conversations.first { $0.id == selectedConversationID }
    }

    var selectedMessages: [ChatMessage] {
        selectedConversation?.messages ?? []
    }

    var canSend: Bool {
        availabilityState == .available
            && !isGenerating
            && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init() {
        refreshAvailability()
    }

    func load() async {
        do {
            let loaded = try await Task.detached {
                try ConversationArchive.load()
            }.value

            conversations = loaded.sorted { $0.updatedAt > $1.updatedAt }
            if let first = conversations.first {
                selectedConversationID = first.id
                restoreSession(for: first)
            } else {
                newConversation()
            }
        } catch {
            archiveErrorMessage = error.localizedDescription
            newConversation()
        }
    }

    func refreshAvailability() {
        switch model.availability {
        case .available:
            availabilityState = .available
        case .unavailable(.appleIntelligenceNotEnabled):
            availabilityState = .appleIntelligenceDisabled
        case .unavailable(.deviceNotEligible):
            availabilityState = .deviceNotEligible
        case .unavailable(.modelNotReady):
            availabilityState = .modelPreparing
        case .unavailable:
            availabilityState = .unavailable
        }
    }

    func newConversation() {
        stopGenerating()

        if let selectedConversation, selectedConversation.messages.isEmpty {
            return
        }

        let conversation = ChatConversation()
        conversations.insert(conversation, at: 0)
        selectedConversationID = conversation.id
        session = makeFreshSession(for: conversation)
        sessionConversationID = conversation.id
        persist()
    }

    func selectConversation(_ id: UUID) {
        guard id != selectedConversationID,
              let conversation = conversations.first(where: { $0.id == id }) else {
            return
        }

        stopGenerating()
        selectedConversationID = id
        restoreSession(for: conversation)
    }

    func deleteConversation(_ id: UUID) {
        if selectedConversationID == id {
            stopGenerating()
        }

        conversations.removeAll { $0.id == id }

        if let first = conversations.first {
            selectedConversationID = first.id
            restoreSession(for: first)
        } else {
            selectedConversationID = nil
            session = nil
            sessionConversationID = nil
            newConversation()
        }
        persist()
    }

    func sendDraft() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, canSend else { return }

        draft = ""
        generationTask = Task { [weak self] in
            await self?.generateResponse(to: prompt)
        }
    }

    func useSuggestion(_ suggestion: String) {
        draft = suggestion
        sendDraft()
    }

    func stopGenerating() {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
    }

    private func generateResponse(to prompt: String) async {
        guard let conversationID = selectedConversationID else { return }
        isGenerating = true

        let userMessage = ChatMessage(role: .user, text: prompt)
        let assistantMessage = ChatMessage(role: .assistant, text: "")
        append(userMessage, to: conversationID)
        append(assistantMessage, to: conversationID)
        updateTitleIfNeeded(prompt, for: conversationID)

        let activeSession: LanguageModelSession
        if sessionConversationID == conversationID, let session {
            activeSession = session
        } else if let conversation = conversations.first(where: { $0.id == conversationID }) {
            activeSession = makeFreshSession(for: conversation)
            session = activeSession
            sessionConversationID = conversationID
        } else {
            isGenerating = false
            return
        }

        do {
            let stream = activeSession.streamResponse(to: prompt)
            for try await snapshot in stream {
                guard !Task.isCancelled else { throw CancellationError() }
                updateMessage(
                    assistantMessage.id,
                    text: snapshot.content,
                    in: conversationID
                )
            }

            let transcriptData = try JSONEncoder().encode(activeSession.transcript)
            updateTranscript(transcriptData, for: conversationID)
        } catch is CancellationError {
            clearTranscript(for: conversationID)
            removeMessageIfEmpty(assistantMessage.id, from: conversationID)
        } catch {
            updateMessage(
                assistantMessage.id,
                text: "I couldn’t complete that response. \(error.localizedDescription)",
                in: conversationID
            )
            clearTranscript(for: conversationID)
        }

        isGenerating = false
        generationTask = nil
        persist()
    }

    private func restoreSession(for conversation: ChatConversation) {
        if let transcriptData = conversation.transcriptData,
           let transcript = try? JSONDecoder().decode(Transcript.self, from: transcriptData) {
            session = LanguageModelSession(model: model, transcript: transcript)
            session?.prewarm()
        } else {
            session = makeFreshSession(for: conversation)
        }
        sessionConversationID = conversation.id
    }

    private func makeFreshSession(for conversation: ChatConversation) -> LanguageModelSession {
        var instructions = """
        You are Aurora, a thoughtful conversational assistant running privately on the user's device.
        Be clear, warm, accurate, and concise by default. Use formatting when it improves readability.
        Never claim to have internet access or knowledge beyond the information available in this session.
        """

        if !conversation.messages.isEmpty {
            let history = conversation.messages
                .filter { !$0.text.isEmpty }
                .map { message in
                    let speaker = message.role == .user ? "User" : "Assistant"
                    return "\(speaker): \(message.text)"
                }
                .joined(separator: "\n\n")
            instructions += "\n\nUse this saved conversation as context:\n\(history)"
        }

        return LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }

    private func append(_ message: ChatMessage, to conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else {
            return
        }
        conversations[index].messages.append(message)
        conversations[index].updatedAt = .now
        moveConversationToTop(at: index)
    }

    private func updateMessage(_ messageID: UUID, text: String, in conversationID: UUID) {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == conversationID }),
              let messageIndex = conversations[conversationIndex].messages.firstIndex(where: {
                  $0.id == messageID
              }) else {
            return
        }

        conversations[conversationIndex].messages[messageIndex].text = text
        conversations[conversationIndex].updatedAt = .now
    }

    private func updateTitleIfNeeded(_ prompt: String, for conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }),
              conversations[index].title == "New conversation" else {
            return
        }

        let shortened = String(prompt.prefix(44))
        conversations[index].title = prompt.count > 44 ? "\(shortened)…" : shortened
    }

    private func updateTranscript(_ data: Data, for conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else {
            return
        }
        conversations[index].transcriptData = data
        conversations[index].updatedAt = .now
    }

    private func clearTranscript(for conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else {
            return
        }
        conversations[index].transcriptData = nil
        session = nil
        sessionConversationID = nil
    }

    private func removeMessageIfEmpty(_ messageID: UUID, from conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else {
            return
        }
        conversations[index].messages.removeAll {
            $0.id == messageID && $0.text.isEmpty
        }
    }

    private func moveConversationToTop(at index: Int) {
        guard index != 0 else { return }
        let conversation = conversations.remove(at: index)
        conversations.insert(conversation, at: 0)
    }

    private func recomputeVisibleConversations() {
        let ordered = conversations
            .filter { !$0.messages.isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            visibleConversations = ordered
        } else {
            visibleConversations = ordered.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.preview.localizedCaseInsensitiveContains(query)
            }
        }
    }

    private func persist() {
        let snapshot = conversations
        Task.detached {
            try? ConversationArchive.save(snapshot)
        }
    }
}
