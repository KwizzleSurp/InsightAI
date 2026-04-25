//
//  InsightsView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.designSystem) private var designSystem
    @Query(sort: \Insight.score, order: .reverse) private var insights: [Insight]
    @Namespace private var namespace
    @State private var selectedCategory: InsightCategory?
    @State private var selectedInsight: Insight?
    
    var filteredInsights: [Insight] {
        guard let category = selectedCategory else { return insights }
        return insights.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: designSystem.spacing.lg) {
                    // Category Filter Bar
                    categoryFilterBar
                    
                    if filteredInsights.isEmpty {
                        emptyState
                    } else {
                        // Stats Header
                        statsHeader
                        
                        // Insights Grid
                        LazyVStack(spacing: designSystem.spacing.md) {
                            ForEach(filteredInsights) { insight in
                                NavigationLink(value: insight) {
                                    InsightCard(insight: insight, namespace: namespace)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, designSystem.spacing.xl)
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Insight.self) { insight in
                InsightDetailView(insight: insight, journalEntry: nil)
            }
        }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsScrollIndicators: false) {
            HStack(spacing: designSystem.spacing.sm) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: designSystem.accentColor
                ) {
                    withAnimation { selectedCategory = nil }
                }
                
                ForEach(InsightCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: .indigo
                    ) {
                        withAnimation { selectedCategory = selectedCategory == category ? nil : category }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var statsHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(filteredInsights.count)")
                    .font(designSystem.typography.largeTitle)
                    .foregroundStyle(designSystem.accentColor)
                Text("Total Insights")
                    .font(designSystem.typography.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                let avgScore = filteredInsights.isEmpty ? 0 : filteredInsights.map(\.score).reduce(0, +) / Double(filteredInsights.count)
                Text(String(format: "%.0f%%", avgScore * 100))
                    .font(designSystem.typography.largeTitle)
                    .foregroundStyle(designSystem.accentColor)
                Text("Avg Confidence")
                    .font(designSystem.typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var emptyState: some View {
        VStack(spacing: designSystem.spacing.md) {
            Image(systemName: "lightbulb")
                .font(.system(size: 48))
                .foregroundStyle(designSystem.accentColor.opacity(0.4))
            Text("No insights yet")
                .font(designSystem.typography.headline)
            Text("Write journal entries to generate AI insights")
                .font(designSystem.typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(designSystem.spacing.xl)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(designSystem.typography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundStyle(isSelected ? .white : color)
                .clipShape(Capsule())
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    InsightsView()
        .environment(\.designSystem, DesignSystem())
        .modelContainer(for: Insight.self, inMemory: true)
}
