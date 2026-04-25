//
//  JournalView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.designSystem) private var designSystem
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Namespace private var namespace
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if entries.isEmpty {
                        emptyStateView
                    } else {
                        entriesList
                    }
                }
                
                FloatingActionButton {
                    showingNewEntry = true
                }
                .padding(designSystem.spacing.lg)
                .padding(.bottom, designSystem.spacing.md)
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export Report", systemImage: "square.and.arrow.up") {
                            // ShareLink handled by profile view
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewEntryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: designSystem.spacing.lg) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(designSystem.accentColor.opacity(0.4))
            
            Text("Your journal is empty")
                .font(designSystem.typography.title2)
                .foregroundStyle(.primary)
            
            Text("Start capturing your thoughts, mood, and energy to unlock AI-powered insights.")
                .font(designSystem.typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Write First Entry") {
                showingNewEntry = true
            }
            .buttonStyle(.borderedProminent)
            .tint(designSystem.accentColor)
            .controlSize(.large)
        }
        .padding(designSystem.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Entries List
    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: designSystem.spacing.md) {
                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        JournalEntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, designSystem.spacing.md)
            .padding(.top, designSystem.spacing.sm)
            .padding(.bottom, 100) // FAB clearance
        }
        .navigationDestination(for: JournalEntry.self) { entry in
            InsightDetailView(insight: nil, journalEntry: entry)
        }
    }
}

#Preview {
    JournalView()
        .environmentObject(NavigationCoordinator())
        .environment(\.designSystem, DesignSystem())
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
