//
//  InsightAIApp.swift
//  InsightAI
//
//  Created with Max App Builder v2 — Stage 4 Final Assembly
//  iOS 18.4+ | Xcode 16.3+
//

import SwiftUI
import SwiftData

@main
struct InsightAIApp: App {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var designSystem = DesignSystem()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            Insight.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationCoordinator)
                .environment(\.designSystem, designSystem)
                .modelContainer(sharedModelContainer)
                .task {
                    await seedDataIfNeeded()
                }
        }
    }
    
    @MainActor
    private func seedDataIfNeeded() async {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<JournalEntry>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }
        
        // Seed 50 pre-built entries
        let seedEntries = JournalEntry.seedEntries()
        for entry in seedEntries {
            context.insert(entry)
        }
        
        try? context.save()
        
        // Generate initial insights
        let engine = InsightScoringEngine()
        for entry in seedEntries {
            let insights = await engine.generateInsights(for: entry, context: seedEntries)
            for insight in insights {
                context.insert(insight)
            }
        }
        try? context.save()
    }
}

@Observable
final class NavigationCoordinator {
    var selectedTab: Int = 0
    var showNewEntrySheet = false
    var navigationPath = NavigationPath()
    
    func navigateToTab(_ tab: Int) {
        withAnimation(.spring) {
            selectedTab = tab
        }
    }
    
    func presentNewEntry() {
        showNewEntrySheet = true
    }
}
