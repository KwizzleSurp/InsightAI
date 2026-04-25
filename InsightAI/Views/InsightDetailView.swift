//
//  InsightDetailView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct InsightDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.designSystem) private var designSystem
    @Environment(\.dismiss) private var dismiss
    @Namespace private var namespace
    
    var insight: Insight?
    var journalEntry: JournalEntry?
    
    @State private var reflectionText = ""
    @State private var showingWhatIf = false
    @State private var isActedOn = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: designSystem.spacing.lg) {
                // Header with score ring
                if let insight = insight {
                    insightHeader(insight)
                } else if let entry = journalEntry {
                    journalEntryHeader(entry)
                }
                
                Divider()
                
                // What-If Section
                if let insight = insight, !insight.whatIf.isEmpty {
                    whatIfSection(insight)
                }
                
                // Reflection Section
                reflectionSection
                
                // Act On It Button
                if let insight = insight, !insight.isActedOn {
                    actOnItButton(insight)
                } else if insight?.isActedOn == true {
                    actedOnBadge
                }
                
                // Related Entry Insights (if viewing journal entry)
                if let entry = journalEntry, !entry.insights.isEmpty {
                    relatedInsightsSection(entry)
                }
            }
            .padding(designSystem.spacing.md)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear {
            if let insight = insight {
                reflectionText = insight.relatedEntry?.reflectionNote ?? ""
                isActedOn = insight.isActedOn
            }
        }
    }
    
    private func insightHeader(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.md) {
            HStack {
                VStack(alignment: .leading) {
                    Text(insight.category.rawValue.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .tracking(1.5)
                    Text(insight.title)
                        .font(designSystem.typography.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                ScoreRing(score: insight.score)
                    .frame(width: 56, height: 56)
            }
            
            Text(insight.content)
                .font(designSystem.typography.body)
                .foregroundStyle(.primary)
            
            Text(insight.createdAt, style: .date)
                .font(designSystem.typography.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func journalEntryHeader(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.md) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.date.formatted(.dateTime.weekday(.wide).month().day()))
                        .font(designSystem.typography.caption)
                        .foregroundStyle(.secondary)
                    Text("Journal Entry")
                        .font(designSystem.typography.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(spacing: 4) {
                    Label("\(entry.mood)/5", systemImage: "face.smiling")
                    Label("\(entry.energy)/5", systemImage: "bolt.fill")
                }
                .font(designSystem.typography.caption)
                .foregroundStyle(.secondary)
            }
            
            Text(entry.content)
                .font(designSystem.typography.body)
            
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsScrollIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(designSystem.accentColor.opacity(0.15))
                                .foregroundStyle(designSystem.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
    
    private func whatIfSection(_ insight: Insight) -> some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.sm) {
            Label("What If?", systemImage: "lightbulb.fill")
                .font(designSystem.typography.headline)
                .foregroundStyle(designSystem.accentColor)
            
            Text(insight.whatIf)
                .font(designSystem.typography.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(designSystem.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.sm) {
            Label("Your Reflection", systemImage: "pencil.and.scribble")
                .font(designSystem.typography.headline)
            
            TextEditor(text: $reflectionText)
                .frame(minHeight: 100)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onChange(of: reflectionText) { _, newValue in
                    if let entry = insight?.relatedEntry ?? journalEntry {
                        entry.reflectionNote = newValue
                        try? modelContext.save()
                    }
                }
        }
    }
    
    private func actOnItButton(_ insight: Insight) -> some View {
        Button {
            withAnimation(.spring) {
                insight.isActedOn = true
                isActedOn = true
                try? modelContext.save()
            }
        } label: {
            Label("Mark as Acted On", systemImage: "checkmark.circle.fill")
                .font(designSystem.typography.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(designSystem.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .sensoryFeedback(.success, trigger: isActedOn)
    }
    
    private var actedOnBadge: some View {
        Label("Acted On!", systemImage: "checkmark.seal.fill")
            .font(designSystem.typography.headline)
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func relatedInsightsSection(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.md) {
            Text("Related Insights")
                .font(designSystem.typography.headline)
            
            ForEach(entry.insights) { relatedInsight in
                NavigationLink(value: relatedInsight) {
                    InsightCard(insight: relatedInsight, namespace: namespace)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InsightDetailView(insight: .sampleInsight, journalEntry: nil)
            .environment(\.designSystem, DesignSystem())
    }
}
