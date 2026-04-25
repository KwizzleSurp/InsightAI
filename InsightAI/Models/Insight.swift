//
//  Insight.swift
//  InsightAI
//

import Foundation
import SwiftData

@Model
final class Insight: Identifiable, Hashable {
    var id: UUID
    var title: String
    var content: String
    var category: InsightCategory
    var score: Double       // 0.1 ... 0.95
    var whatIf: String
    var isActedOn: Bool
    var createdAt: Date
    var entryId: UUID?      // reference to source JournalEntry
    
    // SwiftData back-relationship
    @Relationship(deleteRule: .nullify)
    var relatedEntry: JournalEntry?
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: InsightCategory,
        score: Double,
        whatIf: String = "",
        isActedOn: Bool = false,
        createdAt: Date = Date(),
        entryId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.score = score
        self.whatIf = whatIf
        self.isActedOn = isActedOn
        self.createdAt = createdAt
        self.entryId = entryId
    }
    
    static func == (lhs: Insight, rhs: Insight) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum InsightCategory: String, Codable, CaseIterable {
    case growth = "Growth"
    case wellness = "Wellness"
    case career = "Career"
    case relationships = "Relationships"
    case mindset = "Mindset"
    
    var icon: String {
        switch self {
        case .growth: return "arrow.up.circle.fill"
        case .wellness: return "heart.fill"
        case .career: return "briefcase.fill"
        case .relationships: return "person.2.fill"
        case .mindset: return "brain.head.profile"
        }
    }
}

extension Insight {
    static var sampleInsight: Insight {
        Insight(
            title: "Energy Pattern Detected",
            content: "Your energy peaks on days with morning exercise. You are 73% more productive on these days.",
            category: .wellness,
            score: 0.87,
            whatIf: "What if you blocked 7-8am for movement every weekday?"
        )
    }
}
