//
//  InsightsViewModel.swift
//  InsightAI
//

import SwiftUI
import SwiftData

@Observable
final class InsightsViewModel {
    var insights: [Insight] = []
    var selectedCategory: InsightCategory?
    var isLoading = false
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchInsights()
    }
    
    func fetchInsights() {
        isLoading = true
        let descriptor = FetchDescriptor<Insight>(
            sortBy: [SortDescriptor(\.score, order: .reverse)]
        )
        do {
            insights = try modelContext.fetch(descriptor)
        } catch {
            insights = []
        }
        isLoading = false
    }
    
    var filteredInsights: [Insight] {
        guard let category = selectedCategory else { return insights }
        return insights.filter { $0.category == category }
    }
    
    var highConfidenceInsights: [Insight] {
        insights.filter { $0.score >= 0.65 }
    }
    
    func markActedOn(_ insight: Insight) {
        insight.isActedOn = true
        try? modelContext.save()
    }
    
    func updateReflection(_ insight: Insight, reflection: String) {
        try? modelContext.save()
    }
    
    func insightsByCategory() -> [InsightCategory: [Insight]] {
        Dictionary(grouping: insights, by: { $0.category })
    }
    
    var averageScore: Double {
        guard !insights.isEmpty else { return 0 }
        return insights.map(\.score).reduce(0, +) / Double(insights.count)
    }
}
