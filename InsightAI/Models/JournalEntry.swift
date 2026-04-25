//
//  JournalEntry.swift
//  InsightAI
//

import SwiftUI
import SwiftData
import Foundation

@Model
final class JournalEntry: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var content: String
    var mood: Int        // 1–5
    var energy: Int      // 1–5
    var tags: [String]
    var isActedOn: Bool
    var reflectionNote: String
    
    // Computed for scoring engine
    var moodDelta: Double {
        (Double(mood) - 3.0) / 2.0  // normalized -1...+1
    }
    var energyDelta: Double {
        (Double(energy) - 3.0) / 2.0
    }
    var semanticTags: [String] { tags }
    
    // SwiftData relationship
    @Relationship(deleteRule: .cascade)
    var insights: [Insight] = []
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        content: String,
        mood: Int,
        energy: Int,
        tags: [String] = [],
        isActedOn: Bool = false,
        reflectionNote: String = ""
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.mood = mood
        self.energy = energy
        self.tags = tags
        self.isActedOn = isActedOn
        self.reflectionNote = reflectionNote
    }
    
    // MARK: - Hashable
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Sample & Seed Data
extension JournalEntry {
    static var sampleEntry: JournalEntry {
        JournalEntry(
            content: "Had a productive morning. Finished the main feature and felt really energized.",
            mood: 4,
            energy: 4,
            tags: ["productivity", "work", "focused"]
        )
    }
    
    static func seedEntries() -> [JournalEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        let seedData: [(content: String, mood: Int, energy: Int, tags: [String], daysAgo: Int)] = [
            ("Woke up feeling refreshed. Morning run was incredible, the air was crisp and I felt alive. Ready to tackle the week.", 5, 5, ["exercise", "morning", "energized"], 49),
            ("Tough Monday. Back-to-back meetings drained me. Need to schedule more focus time blocks.", 2, 2, ["work", "meetings", "drained"], 48),
            ("Had lunch with an old friend. Reminded me how important those connections are. Laughed for hours.", 4, 3, ["social", "friendship", "grateful"], 47),
            ("Completed the big presentation. Heart was pounding but I nailed it. Team gave great feedback.", 5, 4, ["work", "proud", "achievement"], 46),
            ("Feeling anxious about the project deadline. Hard to focus. Did some breathing exercises.", 2, 2, ["anxious", "work", "stress"], 45),
            ("Weekend! Went hiking with the family. Kids were amazed by the waterfall. Pure joy.", 5, 5, ["family", "nature", "joy"], 44),
            ("Lazy Sunday. Read half a book, napped twice. No guilt whatsoever.", 4, 2, ["rest", "reading", "recharge"], 43),
            ("Productive deep work session. 4 hours of uninterrupted coding. Flow state achieved.", 5, 4, ["work", "flow", "productivity"], 42),
            ("Argument with a colleague. Feeling frustrated. Need to address the communication gap.", 2, 3, ["work", "conflict", "frustrated"], 41),
            ("Meditated for 20 minutes before work. Noticed a significant difference in my patience levels.", 4, 4, ["mindfulness", "meditation", "calm"], 40),
            ("Got unexpected praise from my manager. Validated all the late nights.", 5, 4, ["work", "recognition", "proud"], 39),
            ("Feeling burnt out. Canceled evening plans and just sat quietly with tea.", 2, 1, ["burnout", "rest", "quiet"], 38),
            ("Started a new side project. The excitement of building something from scratch is addictive.", 5, 5, ["creativity", "side-project", "excited"], 37),
            ("Dentist appointment. Boring but done. Small wins count.", 3, 3, ["errands", "health"], 36),
            ("Deep conversation with my partner about our future plans. Feeling connected and aligned.", 5, 4, ["relationship", "love", "vision"], 35),
            ("Rainy day. Got lost in music for two hours. Rediscovered some old albums.", 4, 3, ["music", "creative", "relax"], 34),
            ("Struggled with self-doubt today. Compared myself to others too much. Need to refocus.", 2, 2, ["mindset", "self-doubt", "growth"], 33),
            ("Team lunch was amazing. We need more of these informal connection moments.", 4, 4, ["team", "social", "culture"], 32),
            ("Finished reading Atomic Habits. So many practical ideas to implement immediately.", 4, 3, ["reading", "learning", "growth"], 31),
            ("Morning yoga + cold shower combo. Felt invincible for 3 hours straight.", 5, 5, ["health", "routine", "energized"], 30),
            ("Project hit a major blocker. Spent 6 hours debugging. Finally found it - a missing semicolon.", 3, 2, ["work", "debugging", "frustrated"], 29),
            ("Volunteered at the community garden. Digging in real soil is surprisingly therapeutic.", 4, 4, ["community", "volunteering", "grounded"], 28),
            ("Had imposter syndrome hit hard during the team review. Reminded myself of my wins.", 2, 3, ["work", "mindset", "imposter"], 27),
            ("Cooked an elaborate meal from scratch. The process was meditative. Result was delicious.", 4, 3, ["cooking", "creative", "home"], 26),
            ("Long walk at sunset. No phone, no podcast. Just thoughts and orange sky.", 5, 4, ["nature", "mindfulness", "peace"], 25),
            ("Sleep has been terrible this week. Can feel the fog in my thinking. Need to prioritize rest.", 1, 1, ["sleep", "health", "tired"], 24),
            ("Got the big client deal! Months of work paying off. Team celebration tonight.", 5, 5, ["work", "success", "celebration"], 23),
            ("Quiet Saturday at home. Organized my desk and cleared mental space.", 3, 3, ["home", "organize", "clarity"], 22),
            ("Interesting workshop on emotional intelligence. Changed how I think about conflict.", 4, 3, ["learning", "workshop", "EQ"], 21),
            ("Ran my first 10K without stopping. Never thought I could do it.", 5, 5, ["exercise", "achievement", "proud"], 20),
            ("Missed gym three days in a row. Slippery slope. Recommitting tomorrow.", 2, 2, ["health", "routine", "accountability"], 19),
            ("Brain dump journaling session. Got 47 random thoughts out of my head.", 4, 3, ["clarity", "journaling", "mental"], 18),
            ("Difficult feedback session with direct report. Growth happens in discomfort.", 3, 3, ["leadership", "work", "growth"], 17),
            ("Spontaneous day trip to the coast. Salt air and waves reset everything.", 5, 5, ["travel", "nature", "spontaneous"], 16),
            ("Feeling grateful. Listed 20 things I\'m thankful for. Simple but powerful.", 5, 4, ["gratitude", "mindfulness", "positive"], 15),
            ("Overthinking a decision that doesn\'t actually matter much. Awareness is step one.", 2, 2, ["mindset", "anxiety", "perspective"], 14),
            ("Had a genuine laugh-until-crying moment with the team. Culture is everything.", 5, 4, ["team", "joy", "laughter"], 13),
            ("Started therapy. Overdue and courageous. Small step, big shift.", 4, 3, ["health", "mental", "growth", "therapy"], 12),
            ("Creative block. Nothing I wrote felt right. Went for a walk, idea struck.", 3, 3, ["creativity", "writing", "block"], 11),
            ("Woke up at 5AM naturally. Golden hour productivity. This might be my thing.", 5, 5, ["routine", "morning", "productive"], 10),
            ("Feeling disconnected from purpose today. Need to revisit my why.", 2, 2, ["purpose", "mindset", "reflection"], 9),
            ("Date night with my partner. No phones. Present and connected.", 5, 4, ["relationship", "love", "present"], 8),
            ("Completed first module of online course. Slow progress is still progress.", 4, 3, ["learning", "growth", "consistency"], 7),
            ("End of month reflection. Hit 7 of 10 goals. Better than last month\'s 4.", 4, 4, ["goals", "reflection", "progress"], 6),
            ("Anxiety spike around finances. Sat with the discomfort instead of avoiding.", 2, 2, ["anxiety", "finances", "courage"], 5),
            ("Evening walk turned into 2-hour exploration of new neighborhoods. Serendipity.", 4, 4, ["exploration", "curiosity", "present"], 4),
            ("Hard conversation with a friend about boundaries. Uncomfortable but necessary.", 3, 3, ["friendship", "growth", "boundaries"], 3),
            ("Flow state in creative work today. Lost 4 hours. Best kind of lost.", 5, 5, ["creativity", "flow", "work"], 2),
            ("Quiet evening. Journaling, tea, rain sounds. Life can be simple and full.", 4, 3, ["gratitude", "simple", "home"], 1),
            ("New day, new chapter. Setting intentions for this week with full clarity and energy.", 4, 4, ["intentions", "clarity", "fresh-start"], 0),
        ]
        
        return seedData.enumerated().map { index, data in
            JournalEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -data.daysAgo, to: now) ?? now,
                content: data.content,
                mood: data.mood,
                energy: data.energy,
                tags: data.tags
            )
        }
    }
}
