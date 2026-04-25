import Foundation
import SwiftData

struct InsightGenerator {
    static func generateInsights(for entry: JournalEntry) -> [Insight] {
        var insights: [Insight] = []
        let lower = entry.content.lowercased()
        
        // Work / Career patterns
        if lower.contains("work") || lower.contains("job") || lower.contains("meeting") || lower.contains("project") {
            insights.append(Insight(
                title: "Work-Life Balance Insight",
                content: "Your entry highlights work intensity. Consider blocking 90 minutes of true disconnection today — your future self will thank you.",
                category: "Career",
                relatedEntryID: entry.id
            ))
        }
        
        // Relationships
        if lower.contains("family") || lower.contains("partner") || lower.contains("friend") || lower.contains("kids") {
            insights.append(Insight(
                title: "Relationship Pattern",
                content: "Connection with loved ones appears in your reflections. Small intentional gestures compound into deeper bonds.",
                category: "Relationships",
                relatedEntryID: entry.id
            ))
        }
        
        // Wellness / Mood
        if entry.mood <= 2 {
            insights.append(Insight(
                title: "Gentle Mood Check-In",
                content: "Today felt heavy. Remember: progress isn't linear. One kind action toward yourself (or someone else) can shift everything.",
                category: "Wellness",
                relatedEntryID: entry.id
            ))
        } else if entry.mood >= 4 && entry.energy >= 4 {
            insights.append(Insight(
                title: "Peak State Captured",
                content: "High mood + high energy day logged. What conditions created this? Replicate them intentionally this week.",
                category: "Growth",
                relatedEntryID: entry.id
            ))
        }
        
        // Energy specific
        if entry.energy <= 2 {
            insights.append(Insight(
                title: "Energy Audit",
                content: "Low energy noted. Prioritize sleep, movement, or a 10-minute nature break tomorrow — your body is asking for restoration.",
                category: "Wellness",
                relatedEntryID: entry.id
            ))
        }
        
        // Growth / mindset
        if lower.contains("learn") || lower.contains("grow") || lower.contains("improve") || lower.contains("goal") {
            insights.append(Insight(
                title: "Growth Mindset Signal",
                content: "You're thinking about growth. That meta-awareness is itself a superpower — keep feeding it with deliberate reflection.",
                category: "Growth",
                relatedEntryID: entry.id
            ))
        }
        
        // Gratitude
        if lower.contains("grateful") || lower.contains("thankful") || lower.contains("appreciate") || lower.contains("blessed") {
            insights.append(Insight(
                title: "Gratitude Amplifier",
                content: "Gratitude detected in your entry. Research shows writing 3 specific gratitudes daily can rewire your brain toward positivity within 21 days.",
                category: "Wellness",
                relatedEntryID: entry.id
            ))
        }
        
        // Default reflective insight
        if insights.isEmpty {
            insights.append(Insight(
                title: "Daily Reflection Anchor",
                content: "Thank you for showing up for yourself today. Consistent reflection is one of the highest-leverage habits for long-term fulfillment.",
                category: "Growth",
                relatedEntryID: entry.id
            ))
        }
        
        return insights
    }
    
    // Generate what-if scenarios for a given entry
    static func generateWhatIfScenarios(for entry: JournalEntry) -> [String] {
        var scenarios: [String] = []
        
        if entry.mood < 3 {
            scenarios.append("What if you had taken a 10-minute walk before that moment?")
            scenarios.append("What if you had shared how you were feeling with someone you trust?")
        }
        if entry.energy < 3 {
            scenarios.append("What if you had protected 30 extra minutes of sleep last night?")
        }
        scenarios.append("What if you approached tomorrow with the wisdom from today's reflection?")
        return scenarios
    }
}
