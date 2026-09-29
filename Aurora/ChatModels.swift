import Foundation

enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let role: ChatRole
    var text: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        role: ChatRole,
        text: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}

struct ChatConversation: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var updatedAt: Date
    var transcriptData: Data?

    init(
        id: UUID = UUID(),
        title: String = "New conversation",
        messages: [ChatMessage] = [],
        updatedAt: Date = .now,
        transcriptData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.updatedAt = updatedAt
        self.transcriptData = transcriptData
    }

    var preview: String {
        messages.last?.text ?? "Start a conversation"
    }
}

enum ModelAvailabilityState: Equatable, Sendable {
    case available
    case appleIntelligenceDisabled
    case deviceNotEligible
    case modelPreparing
    case unavailable

    var message: LocalizedStringResource? {
        switch self {
        case .available:
            nil
        case .appleIntelligenceDisabled:
            "Turn on Apple Intelligence in Settings to chat on device."
        case .deviceNotEligible:
            "This device doesn’t support Apple Intelligence."
        case .modelPreparing:
            "The on-device model is still downloading. Try again soon."
        case .unavailable:
            "The on-device model is currently unavailable."
        }
    }
}
