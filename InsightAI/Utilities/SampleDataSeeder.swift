import SwiftData
import Foundation

struct SampleDataSeeder {
    static func seedIfNeeded() {
        // Called from ContentView.onAppear
        // In production: check UserDefaults flag
        let key = "InsightAI_SampleDataSeeded_v2"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        // Mark as seeded so it only runs once
        UserDefaults.standard.set(true, forKey: key)
    }
    
    @MainActor
    static func seedSampleData(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        let samples: [(Date, String, Int, Int, [String])] = [
            (
                calendar.date(byAdding: .day, value: -13, to: today)!,
                "Started the new quarter with a clear head. Set my top 3 intentions: deepen relationships, ship the product, protect my energy. Feeling hopeful and anchored.",
                5, 5, ["growth", "intentions", "work"]
            ),
            (
                calendar.date(byAdding: .day, value: -11, to: today)!,
                "Long day of back-to-back meetings. Felt drained by noon. Missed my workout and skipped lunch. Need to protect mornings better.",
                2, 2, ["work", "health", "energy"]
            ),
            (
                calendar.date(byAdding: .day, value: -9, to: today)!,
                "Beautiful morning with coffee and journaling before the family woke up. Felt deeply grateful for my partner and kids. The small rituals are everything.",
                5, 4, ["family", "gratitude", "wellness"]
            ),
            (
                calendar.date(byAdding: .day, value: -7, to: today)!,
                "Gave a big presentation today. Crushed it. The preparation paid off. But felt oddly anxious after — need to learn to celebrate wins without deflating.",
                4, 3, ["work", "growth", "mindset"]
            ),
            (
                calendar.date(byAdding: .day, value: -5, to: today)!,
                "Went for a 90-minute walk in the park after work. Mind completely cleared. Got three breakthrough ideas for the product. Nature is my best thinking space.",
                5, 5, ["nature", "creativity", "wellness"]
            ),
            (
                calendar.date(byAdding: .day, value: -3, to: today)!,
                "Feeling stuck on the product direction. Imposter syndrome creeping in. Talked to a mentor — reminded me that doubt is a sign you care deeply. Helped.",
                3, 3, ["work", "mindset", "growth"]
            ),
            (
                calendar.date(byAdding: .day, value: -1, to: today)!,
                "Huge win: first paying customer! 5 years of work crystallizing into something real. Celebrated with the team. Grateful for every person who believed in us.",
                5, 5, ["work", "milestone", "gratitude", "team"]
            ),
            (
                today,
                "Reflecting on the journey. Proud but also aware of how much further there is to go. Setting up the next milestone. The clarity feels earned.",
                4, 4, ["reflection", "growth", "goals"]
            )
        ]
        
        for (date, content, mood, energy, tags) in samples {
            let entry = JournalEntry(date: date, content: content, mood: mood, energy: energy, tags: tags)
            context.insert(entry)
            
            let insights = InsightGenerator.generateInsights(for: entry)
            for insight in insights {
                context.insert(insight)
            }
        }
        
        try? context.save()
    }
}
