import SwiftUI

struct ChatHistoryView: View {
    @Bindable var store: ChatStore
    let theme: GradientTheme

    var body: some View {
        ZStack {
            SiriGradientBackground(theme: theme)
                .ignoresSafeArea()

            if store.visibleConversations.isEmpty {
                ContentUnavailableView(
                    "No Conversations Yet",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Your on-device conversation history will appear here.")
                )
            } else {
                List {
                    Section("Conversations") {
                        ForEach(store.visibleConversations) { conversation in
                            NavigationLink {
                                ChatScreen(store: store, theme: theme)
                                    .onAppear {
                                        store.selectConversation(conversation.id)
                                    }
                            } label: {
                                ConversationHistoryRow(
                                    title: conversation.title,
                                    preview: conversation.preview,
                                    date: conversation.updatedAt,
                                    isSelected: conversation.id == store.selectedConversationID
                                )
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    store.deleteConversation(conversation.id)
                                }
                            }
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    store.deleteConversation(conversation.id)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("History")
        .searchable(text: $store.searchQuery, prompt: "Search conversations")
    }
}

struct ConversationHistoryRow: View {
    let title: String
    let preview: String
    let date: Date
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .foregroundStyle(.primary.opacity(0.8))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(date, format: .dateTime.month(.abbreviated).day())
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .glassEffect(
            isSelected ? .regular.tint(.blue.opacity(0.35)) : .clear,
            in: .rect(cornerRadius: 16)
        )
    }
}

struct ChatScreen: View {
    let store: ChatStore
    let theme: GradientTheme

    var body: some View {
        @Bindable var store = store

        ZStack {
            SiriGradientBackground(theme: theme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if store.selectedMessages.isEmpty {
                    WelcomeView(onSuggestion: store.useSuggestion)
                } else {
                    MessageList(
                        messages: store.selectedMessages,
                        isGenerating: store.isGenerating
                    )
                }

                if let message = store.availabilityState.message {
                    AvailabilityBanner(
                        message: message,
                        onRefresh: store.refreshAvailability
                    )
                }

                ChatComposer(
                    draft: $store.draft,
                    canSend: store.canSend,
                    isGenerating: store.isGenerating,
                    onSend: store.sendDraft,
                    onStop: store.stopGenerating
                )
            }
        }
        .navigationTitle(store.selectedConversation?.title ?? "Aurora")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.newConversation()
                } label: {
                    Label("New Chat", systemImage: "square.and.pencil")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.glass)
                .accessibilityHint("Starts a separate conversation")
            }
        }
    }
}

struct WelcomeView: View {
    let onSuggestion: (String) -> Void

    private let suggestions: [PromptSuggestion] = [
        PromptSuggestion(
            id: "brainstorm",
            icon: "lightbulb.max.fill",
            title: "Brainstorm",
            prompt: "Help me brainstorm a creative weekend project."
        ),
        PromptSuggestion(
            id: "rewrite",
            icon: "text.badge.checkmark",
            title: "Rewrite",
            prompt: "Help me rewrite something to sound clear and confident."
        ),
        PromptSuggestion(
            id: "learn",
            icon: "graduationcap.fill",
            title: "Learn",
            prompt: "Teach me an interesting concept in five minutes."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 80)

                Image(systemName: "apple.intelligence")
                    .font(.system(size: 58, weight: .medium))
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: .purple.opacity(0.55), radius: 24)

                VStack(spacing: 8) {
                    Text("What can I help with?")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text("Private, on-device intelligence powered by Apple")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                GlassEffectContainer(spacing: 14) {
                    VStack(spacing: 12) {
                        ForEach(suggestions) { suggestion in
                            SuggestionButton(
                                icon: suggestion.icon,
                                title: suggestion.title,
                                prompt: suggestion.prompt,
                                onSelect: onSuggestion
                            )
                        }
                    }
                }
                .frame(maxWidth: 520)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct PromptSuggestion: Identifiable {
    let id: String
    let icon: String
    let title: LocalizedStringResource
    let prompt: String
}

private struct SuggestionButton: View {
    let icon: String
    let title: LocalizedStringResource
    let prompt: String
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(prompt)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(.primary.opacity(0.9))

                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
    }
}

struct MessageList: View {
    let messages: [ChatMessage]
    let isGenerating: Bool

    private let bottomID = "conversation-bottom"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(messages) { message in
                        MessageRow(
                            role: message.role,
                            text: message.text,
                            isStreaming: isGenerating
                                && message.id == messages.last?.id
                                && message.role == .assistant
                        )
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                .frame(maxWidth: 820)
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
            .onChange(of: messages.last?.text) {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
}

struct MessageRow: View {
    let role: ChatRole
    let text: String
    let isStreaming: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if role == .assistant {
                Image(systemName: "apple.intelligence")
                    .font(.title3)
                    .frame(width: 34, height: 34)
                    .glassEffect(.regular.tint(.purple.opacity(0.28)), in: .circle)
            } else {
                Spacer(minLength: 54)
            }

            VStack(alignment: .leading, spacing: 8) {
                if text.isEmpty && isStreaming {
                    ThinkingIndicator()
                } else {
                    Text(markdownText)
                        .font(.body)
                        .textSelection(.enabled)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(
                role == .user
                    ? .regular.tint(.blue.opacity(0.32))
                    : .regular,
                in: .rect(cornerRadius: 22)
            )

            if role == .user {
                Image(systemName: "person.fill")
                    .font(.subheadline)
                    .frame(width: 34, height: 34)
                    .glassEffect(.regular, in: .circle)
            } else {
                Spacer(minLength: 34)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var markdownText: AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

struct ThinkingIndicator: View {
    var body: some View {
        HStack(spacing: 6) {
            ProgressView()
                .controlSize(.small)
            Text("Thinking…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct AvailabilityBanner: View {
    let message: LocalizedStringResource
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "apple.intelligence")
                .foregroundStyle(.yellow)

            Text(message)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Check again", action: onRefresh)
                .font(.footnote.bold())
                .buttonStyle(.glass)
        }
        .padding(12)
        .glassEffect(.regular.tint(.orange.opacity(0.18)), in: .rect(cornerRadius: 18))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct ChatComposer: View {
    @Binding var draft: String
    let canSend: Bool
    let isGenerating: Bool
    let onSend: () -> Void
    let onStop: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            VStack(spacing: 10) {
                TextField("Message Aurora", text: $draft, axis: .vertical)
                    .lineLimit(1...6)
                    .submitLabel(.send)
                    .onSubmit(onSend)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))

                Button {
                    isGenerating ? onStop() : onSend()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isGenerating ? "stop.fill" : "arrow.up")
                        Text(isGenerating ? "Stop generating" : "Send message")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.glassProminent)
                .disabled(!isGenerating && !canSend)
                .accessibilityHint(
                    isGenerating
                        ? "Stops the current response"
                        : "Submits your message to the on-device model"
                )
            }
            .frame(maxWidth: 720)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
