//
//  JournalViewModel.swift
//  InsightAI
//

import SwiftUI
import SwiftData

@Observable
final class JournalViewModel {
    var entries: [JournalEntry] = []
    var isLoading = false
    var errorMessage: String?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchEntries()
    }
    
    // MARK: - Fetch
    func fetchEntries() {
        isLoading = true
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            entries = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Create
    func createEntry(
        content: String,
        mood: Int,
        energy: Int,
        tags: [String]
    ) async {
        let entry = JournalEntry(
            content: content,
            mood: mood,
            energy: energy,
            tags: tags
        )
        modelContext.insert(entry)
        try? modelContext.save()
        
        // Generate insights asynchronously
        let engine = InsightScoringEngine()
        let context = entries
        let insights = await engine.generateInsights(for: entry, context: context)
        for insight in insights {
            insight.relatedEntry = entry
            modelContext.insert(insight)
        }
        try? modelContext.save()
        fetchEntries()
    }
    
    // MARK: - Delete
    func deleteEntry(_ entry: JournalEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        fetchEntries()
    }
    
    func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
        fetchEntries()
    }
    
    // MARK: - Update
    func updateEntry(_ entry: JournalEntry, reflectionNote: String) {
        entry.reflectionNote = reflectionNote
        try? modelContext.save()
    }
    
    func markActedOn(_ entry: JournalEntry) {
        entry.isActedOn = true
        try? modelContext.save()
    }
    
    // MARK: - Stats
    var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.mood).reduce(0, +)) / Double(entries.count)
    }
    
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        for entry in entries {
            if calendar.isDate(entry.date, inSameDayAs: checkDate) ||
               calendar.isDate(entry.date, inSameDayAs: calendar.date(byAdding: .day, value: -streak, to: Date())!) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    func exportReport() -> String {
        let lines = entries.map { entry in
            "Date: \(entry.date.formatted())\nMood: \(entry.mood)/5\nEnergy: \(entry.energy)/5\nTags: \(entry.tags.joined(separator: ", "))\nContent: \(entry.content)\n"
        }
        return lines.joined(separator: "\n---\n")
    }
}
