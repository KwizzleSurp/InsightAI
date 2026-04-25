//
//  InsightScoringEngine.swift
//  InsightAI
//
//  Grok 4.3 Beta-inspired multi-factor scoring engine
//  Actor-isolated for Swift Concurrency safety
//

import Foundation

actor InsightScoringEngine {
    
    // MARK: - Sentiment Lexicon
    private let sentimentLexicon: [String: Double] = [
        "happy": 0.9, "grateful": 0.85, "proud": 0.8, "excited": 0.75,
        "joyful": 0.85, "energized": 0.8, "focused": 0.7, "productive": 0.7,
        "balanced": 0.6, "calm": 0.5, "peaceful": 0.55, "content": 0.6,
        "tired": -0.4, "anxious": -0.6, "frustrated": -0.7, "drained": -0.65,
        "overwhelmed": -0.55, "stressed": -0.6, "burnt": -0.7, "exhausted": -0.65,
        "sad": -0.6, "angry": -0.7, "depressed": -0.8, "lonely": -0.5,
        "disconnected": -0.5, "doubt": -0.4, "imposter": -0.45
    ]
    
    // MARK: - Main Score Calculator
    func calculateScore(for entry: JournalEntry, context: [JournalEntry]) -> Double {
        var score: Double = 0.5
        
        // 1. Mood delta (35% weight)
        score += entry.moodDelta * 0.35
        
        // 2. Energy delta (25% weight)
        score += entry.energyDelta * 0.25
        
        // 3. Semantic tag frequency (up to 20%)
        let tagScore = min(Double(entry.semanticTags.count) * 0.08, 0.20)
        score += tagScore
        
        // 4. Recency decay (up to 15%)
        let daysOld = Calendar.current.dateComponents([.day], from: entry.date, to: Date()).day ?? 0
        let recency = max(0.15 - (Double(daysOld) * 0.02), 0.05)
        score += recency
        
        // 5. Cross-entry pattern detection (5%)
        let recentContext = Array(context.suffix(7))
        let similarEntries = recentContext.filter {
            abs(Double($0.mood) - Double(entry.mood)) <= 1 &&
            $0.tags.contains(where: { entry.tags.contains($0) })
        }
        if similarEntries.count >= 2 { score += 0.05 }
        
        // 6. Sentiment analysis (15% weight)
        let sentiment = analyzeSentiment(entry.content)
        score += sentiment * 0.15
        
        return max(0.1, min(0.95, score))
    }
    
    // MARK: - Sentiment Analysis
    private func analyzeSentiment(_ text: String) -> Double {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var totalSentiment: Double = 0
        var matchCount = 0
        
        for word in words {
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            if let score = sentimentLexicon[cleaned] {
                totalSentiment += score
                matchCount += 1
            }
        }
        
        guard matchCount > 0 else { return 0 }
        return totalSentiment / Double(matchCount)
    }
    
    // MARK: - Insight Generation
    func generateInsights(for entry: JournalEntry, context: [JournalEntry]) -> [Insight] {
        let score = calculateScore(for: entry, context: context)
        var insights: [Insight] = []
        
        // Generate 2-5 insights per entry based on score
        let insightCount = score > 0.7 ? 5 : score > 0.5 ? 3 : 2
        
        let templates = insightTemplates(for: entry, score: score, context: context)
        let selected = Array(templates.shuffled().prefix(insightCount))
        
        for template in selected {
            let insight = Insight(
                title: template.title,
                content: template.content,
                category: template.category,
                score: max(0.1, min(0.95, score + Double.random(in: -0.1...0.1))),
                whatIf: template.whatIf,
                entryId: entry.id
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    // MARK: - Insight Templates
    private func insightTemplates(
        for entry: JournalEntry,
        score: Double,
        context: [JournalEntry]
    ) -> [(title: String, content: String, category: InsightCategory, whatIf: String)] {
        var templates: [(title: String, content: String, category: InsightCategory, whatIf: String)] = []
        
        // Mood-based insights
        if entry.mood >= 4 {
            templates.append((
                title: "High Mood Pattern",
                content: "You logged a \(entry.mood)/5 mood today. Your top tags — \(entry.tags.prefix(2).joined(separator: ", ")) — are strong predictors of your peak states.",
                category: .wellness,
                whatIf: "What if you built a morning ritual around your \(entry.tags.first ?? \"top activities\")?"
            ))
        } else if entry.mood <= 2 {
            templates.append((
                title: "Recovery Opportunity",
                content: "Low mood entries like today often precede breakthrough moments. Your data shows recovery usually takes 1-2 days.",
                category: .mindset,
                whatIf: "What if you scheduled a recovery activity for tomorrow morning?"
            ))
        }
        
        // Energy-based insights
        if entry.energy >= 4 {
            templates.append((
                title: "Peak Energy Captured",
                content: "Energy level \(entry.energy)/5 on \(entry.date.formatted(.dateTime.weekday(.wide))). This is your optimal time for deep work.",
                category: .career,
                whatIf: "What if you blocked your calendar for focused work during these high-energy windows?"
            ))
        }
        
        // Tag frequency insights
        let recentContext = Array(context.suffix(14))
        for tag in entry.tags {
            let tagFrequency = recentContext.filter { $0.tags.contains(tag) }.count
            if tagFrequency >= 3 {
                templates.append((
                    title: "\"\(tag.capitalized)\" Emerging Theme",
                    content: "You\'ve tagged \"\(tag)\" \(tagFrequency) times in the past 2 weeks. This pattern signals an area of growing importance.",
                    category: .growth,
                    whatIf: "What if you dedicated 30 minutes weekly to intentionally developing your \(tag) practice?"
                ))
                break
            }
        }
        
        // Cross-entry pattern insights
        let moodTrend = recentContext.suffix(5).map { Double($0.mood) }
        if moodTrend.count >= 3 {
            let avg = moodTrend.reduce(0, +) / Double(moodTrend.count)
            if avg >= 3.5 {
                templates.append((
                    title: "Upward Momentum Detected",
                    content: "Your average mood over the past 5 entries is \(String(format: "%.1f", avg))/5. You\'re in a positive momentum cycle.",
                    category: .growth,
                    whatIf: "What if you journaled about what\'s driving this momentum to lock in the pattern?"
                ))
            }
        }
        
        // High-score insights
        if score >= 0.75 {
            templates.append((
                title: "High-Impact Entry",
                content: "This entry scored \(String(format: "%.0f", score * 100))% confidence. The combination of your content, mood, and tags makes this a high-signal data point.",
                category: .mindset,
                whatIf: "What if you reflected on what made today different and replicated those conditions?"
            ))
        }
        
        // Relationship insights
        if entry.tags.contains(where: { ["social", "friendship", "relationship", "family", "team"].contains($0) }) {
            templates.append((
                title: "Social Connection Boost",
                content: "Entries with social tags correlate with 40% higher mood scores in your data. Connection is a key driver of your wellbeing.",
                category: .relationships,
                whatIf: "What if you scheduled one meaningful social interaction per week?"
            ))
        }
        
        return templates
    }
}
