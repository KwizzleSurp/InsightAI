//
//  ContentView.swift
//  InsightAI
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.designSystem) private var designSystem
    @Namespace private var tabNamespace
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: coordinator.selectedTab == 0 ? "book.fill" : "book")
                }
                .tag(0)
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: coordinator.selectedTab == 1 ? "lightbulb.fill" : "lightbulb")
                }
                .tag(1)
            
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: coordinator.selectedTab == 2 ? "calendar.circle.fill" : "calendar.circle")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: coordinator.selectedTab == 3 ? "person.circle.fill" : "person.circle")
                }
                .tag(3)
        }
        .tint(designSystem.accentColor)
        .sheet(isPresented: $coordinator.showNewEntrySheet) {
            NewEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
        .environment(\.designSystem, DesignSystem())
}
