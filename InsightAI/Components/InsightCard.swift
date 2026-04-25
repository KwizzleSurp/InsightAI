//
//  InsightCard.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct InsightCard: View {
    let insight: Insight
    let namespace: Namespace.ID
    var isDetail: Bool = false
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.sm) {
            // Header row
            HStack(alignment: .top) {
                // Category icon circle
                Circle()
                    .fill(categoryGradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: insight.category.icon)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(designSystem.typography.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(insight.category.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                }
                
                Spacer()
                
                // Score Ring
                ScoreRing(score: insight.score)
                    .frame(width: 40, height: 40)
            }
            
            // Content
            Text(insight.content)
                .font(designSystem.typography.body)
                .foregroundStyle(.primary)
                .lineLimit(isDetail ? nil : 3)
            
            // What-If preview (if exists)
            if !insight.whatIf.isEmpty && !isDetail {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption2)
                        .foregroundStyle(designSystem.accentColor)
                    Text(insight.whatIf)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            
            // Footer
            HStack {
                Text(insight.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                if insight.isActedOn {
                    Label("Acted On", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(designSystem.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(scoreGlow)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(scoreGlowBorder, lineWidth: 1)
        )
        .shadow(color: glowColor.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    
    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [categoryColor, categoryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var scoreGlow: LinearGradient {
        LinearGradient(
            colors: [glowColor.opacity(0.08), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var scoreGlowBorder: LinearGradient {
        LinearGradient(
            colors: [glowColor.opacity(0.4), glowColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var glowColor: Color {
        insight.score >= 0.7 ? .green : insight.score >= 0.5 ? designSystem.accentColor : .gray
    }
    
    private var categoryColor: Color {
        switch insight.category {
        case .growth: return .green
        case .wellness: return .blue
        case .career: return designSystem.accentColor
        case .relationships: return .pink
        case .mindset: return .indigo
        }
    }
}

#Preview {
    InsightCard(insight: .sampleInsight, namespace: Namespace().wrappedValue)
        .environment(\.designSystem, DesignSystem())
        .padding()
        .background(.regularMaterial)
}
