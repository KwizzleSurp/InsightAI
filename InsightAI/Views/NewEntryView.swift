//
//  NewEntryView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.designSystem) private var designSystem
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var mood: Double = 3
    @State private var energy: Double = 3
    @State private var tags: [String] = []
    @State private var isSaving = false
    @State private var step = 0  // 0=write, 1=mood, 2=energy, 3=tags
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: designSystem.spacing.lg) {
                    StepIndicator(currentStep: step, totalSteps: 4)
                        .padding(.horizontal)
                    
                    switch step {
                    case 0:
                        journalTextStep
                    case 1:
                        moodStep
                    case 2:
                        energyStep
                    case 3:
                        tagsStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.vertical, designSystem.spacing.md)
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if step < 3 {
                        Button("Next") {
                            withAnimation(.spring) { step += 1 }
                        }
                        .disabled(step == 0 && content.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button("Save") {
                            Task { await saveEntry() }
                        }
                        .disabled(isSaving)
                        .bold()
                    }
                }
                if step > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { withAnimation(.spring) { step -= 1 } }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Steps
    private var journalTextStep: some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.md) {
            Text("How was your day? What\'s on your mind?")
                .font(designSystem.typography.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            TextEditor(text: $content)
                .frame(minHeight: 200)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            
            VoiceWaveformStub()
                .padding(.horizontal)
        }
    }
    
    private var moodStep: some View {
        VStack(spacing: designSystem.spacing.md) {
            moodEmoji
                .font(.system(size: 72))
                .sensoryFeedback(.selection, trigger: mood)
            
            CustomSlider(
                value: $mood,
                label: "Mood",
                icon: "face.smiling",
                range: 1...5
            )
            .padding(.horizontal)
        }
    }
    
    private var energyStep: some View {
        VStack(spacing: designSystem.spacing.md) {
            Text(energyLabel)
                .font(.system(size: 48))
                .sensoryFeedback(.selection, trigger: energy)
            
            CustomSlider(
                value: $energy,
                label: "Energy",
                icon: "bolt.fill",
                range: 1...5
            )
            .padding(.horizontal)
        }
    }
    
    private var tagsStep: some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.md) {
            Text("Add tags to help the AI find patterns")
                .font(designSystem.typography.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            TagChipEditor(tags: $tags)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Helpers
    private var stepTitle: String {
        ["What happened?", "How\'s your mood?", "Your energy level?", "Add tags"][step]
    }
    
    private var moodEmoji: Text {
        let emojis = ["", "😔", "😕", "😐", "🙂", "😄"]
        return Text(emojis[Int(mood)])
    }
    
    private var energyLabel: String {
        ["Very Low", "Low", "Moderate", "High", "Peak"][Int(energy) - 1]
    }
    
    @MainActor
    private func saveEntry() async {
        isSaving = true
        let entry = JournalEntry(
            content: content,
            mood: Int(mood),
            energy: Int(energy),
            tags: tags
        )
        modelContext.insert(entry)
        
        let allEntries = (try? modelContext.fetch(FetchDescriptor<JournalEntry>())) ?? []
        let engine = InsightScoringEngine()
        let insights = await engine.generateInsights(for: entry, context: allEntries)
        for insight in insights {
            insight.relatedEntry = entry
            modelContext.insert(insight)
        }
        try? modelContext.save()
        isSaving = false
        dismiss()
    }
}

#Preview {
    NewEntryView()
        .environment(\.designSystem, DesignSystem())
        .modelContainer(for: [JournalEntry.self, Insight.self], inMemory: true)
}
