import SwiftUI

private enum AppTab: Hashable {
    case newChat
    case history
    case settings
}

struct ContentView: View {
    @State private var store = ChatStore()
    @State private var selectedTab: AppTab = .newChat
    @AppStorage("selectedGradientTheme")
    private var selectedTheme: GradientTheme = .siriSpectrum

    var body: some View {
        @Bindable var store = store

        TabView(selection: $selectedTab) {
            Tab("New Chat", systemImage: "square.and.pencil", value: .newChat) {
                NavigationStack {
                    ChatScreen(store: store, theme: selectedTheme)
                }
            }

            Tab("History", systemImage: "clock.arrow.circlepath", value: .history) {
                NavigationStack {
                    ChatHistoryView(store: store, theme: selectedTheme)
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                NavigationStack {
                    SettingsView(selectedTheme: $selectedTheme)
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            await store.load()
            store.newConversation()
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            if newTab == .newChat, oldTab != .newChat {
                store.newConversation()
            }
        }
        .alert(
            "Conversation history couldn’t be loaded",
            isPresented: $store.isShowingArchiveError
        ) {
            Button("OK", role: .cancel) {
                store.archiveErrorMessage = nil
            }
        } message: {
            Text(store.archiveErrorMessage ?? "")
        }
    }
}

#Preview {
    ContentView()
}
