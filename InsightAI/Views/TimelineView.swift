//
//  TimelineView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.designSystem) private var designSystem
    @Query(sort: \JournalEntry.date, order: .reverse) private var allEntries: [JournalEntry]
    @State private var searchText = ""
    @State private var selectedMoodFilter: Int? = nil
    
    var filteredEntries: [JournalEntry] {
        var entries = allEntries
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        if let moodFilter = selectedMoodFilter {
            entries = entries.filter { $0.mood == moodFilter }
        }
        return entries
    }
    
    var groupedEntries: [(key: String, entries: [JournalEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: entry.date)
        }
        return grouped
            .sorted { a, b in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let dateA = formatter.date(from: a.key) ?? Date.distantPast
                let dateB = formatter.date(from: b.key) ?? Date.distantPast
                return dateA > dateB
            }
            .map { (key: $0.key, entries: $0.value.sorted { $0.date > $1.date }) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Mood Filter Pills
                    moodFilterBar
                        .padding(.vertical, designSystem.spacing.sm)
                    
                    if groupedEntries.isEmpty {
                        emptyState
                    } else {
                        // Timeline sections
                        ForEach(groupedEntries, id: \.key) { group in
                            TimelineSection(
                                title: group.key,
                                entries: group.entries,
                                designSystem: designSystem
                            )
                        }
                    }
                }
                .padding(.bottom, designSystem.spacing.xl)
            }
            .navigationTitle("Timeline")
            .searchable(text: $searchText, prompt: "Search entries or tags")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var moodFilterBar: some View {
        ScrollView(.horizontal, showsScrollIndicators: false) {
            HStack(spacing: designSystem.spacing.sm) {
                FilterChip(title: "All", isSelected: selectedMoodFilter == nil, color: designSystem.accentColor) {
                    withAnimation { selectedMoodFilter = nil }
                }
                ForEach(1...5, id: \.self) { mood in
                    let emojis = ["😔", "😕", "😐", "🙂", "😄"]
                    FilterChip(
                        title: emojis[mood - 1],
                        isSelected: selectedMoodFilter == mood,
                        color: moodColor(mood)
                    ) {
                        withAnimation { selectedMoodFilter = selectedMoodFilter == mood ? nil : mood }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: designSystem.spacing.md) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "No entries found" : "No results for \"\(searchText)\"")
                .font(designSystem.typography.headline)
            if !searchText.isEmpty {
                Button("Clear Search") { searchText = "" }
                    .tint(designSystem.accentColor)
            }
        }
        .padding(designSystem.spacing.xl)
    }
    
    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1, 2: return .red
        case 3: return .orange
        case 4, 5: return .green
        default: return .gray
        }
    }
}

struct TimelineSection: View {
    let title: String
    let entries: [JournalEntry]
    let designSystem: DesignSystem
    @Namespace private var namespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(designSystem.typography.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, designSystem.spacing.md)
                .padding(.vertical, designSystem.spacing.sm)
            
            ForEach(entries) { entry in
                HStack(alignment: .top, spacing: designSystem.spacing.sm) {
                    // Timeline line + dot
                    VStack(spacing: 0) {
                        Circle()
                            .fill(moodColor(entry.mood))
                            .frame(width: 12, height: 12)
                            .padding(.top, 6)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 2)
                    }
                    .frame(width: 20)
                    
                    NavigationLink(value: entry) {
                        JournalEntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, designSystem.spacing.sm)
                }
                .padding(.horizontal, designSystem.spacing.md)
            }
        }
    }
    
    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1, 2: return .red
        case 3: return .orange
        case 4, 5: return .green
        default: return .gray
        }
    }
}

#Preview {
    TimelineView()
        .environment(\.designSystem, DesignSystem())
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
