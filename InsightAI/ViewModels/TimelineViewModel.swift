//
//  TimelineViewModel.swift
//  InsightAI
//

import SwiftUI
import SwiftData

@Observable
final class TimelineViewModel {
    var allEntries: [JournalEntry] = []
    var searchText: String = ""
    var selectedMoodFilter: Int? = nil
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchEntries()
    }
    
    func fetchEntries() {
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        allEntries = (try? modelContext.fetch(descriptor)) ?? []
    }
    
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
    
    var moodTrendData: [(date: Date, mood: Int)] {
        Array(allEntries.prefix(30)).map { (date: $0.date, mood: $0.mood) }.reversed()
    }
    
    func clearFilters() {
        searchText = ""
        selectedMoodFilter = nil
    }
}
