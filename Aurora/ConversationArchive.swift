import Foundation

enum ConversationArchive {
    private static nonisolated var archiveURL: URL {
        let directory = URL.applicationSupportDirectory
            .appending(path: "Aurora", directoryHint: .isDirectory)
        return directory.appending(path: "conversations.json")
    }

    static nonisolated func load() throws -> [ChatConversation] {
        let url = archiveURL
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ChatConversation].self, from: data)
    }

    static nonisolated func save(_ conversations: [ChatConversation]) throws {
        let url = archiveURL
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(conversations)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }
}
