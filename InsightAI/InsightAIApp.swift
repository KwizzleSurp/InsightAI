import SwiftUI
import SwiftData

@main
struct InsightAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.designSystem, DesignSystem())
                .environment(NavigationCoordinator())
        }
        .modelContainer(for: [JournalEntry.self, Insight.self])
    }
}
