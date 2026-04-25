//
//  ProfileView.swift
//  InsightAI
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.designSystem) private var designSystem
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query(sort: \Insight.score, order: .reverse) private var insights: [Insight]
    @State private var showingThemePicker = false
    @State private var showingPrivacySettings = false
    @State private var showingExport = false
    
    // Stats
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        for entry in entries {
            let entryDay = calendar.startOfDay(for: entry.date)
            if entryDay == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if entryDay < checkDate {
                break
            }
        }
        return max(streak, 1)
    }
    
    var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.mood).reduce(0, +)) / Double(entries.count)
    }
    
    var weeklyEntries: [JournalEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return entries.filter { $0.date >= weekAgo }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: designSystem.spacing.lg) {
                    // Streak Ring Hero
                    streakSection
                    
                    // Weekly Stats
                    weeklyStatsGrid
                    
                    // Settings Sections
                    settingsSection
                }
                .padding(.bottom, designSystem.spacing.xl)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerSheet()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: designSystem.spacing.md) {
            StreakRingView(streak: currentStreak, maxStreak: max(currentStreak, 30))
                .frame(width: 140, height: 140)
            
            VStack(spacing: 4) {
                Text("\(currentStreak) Day Streak")
                    .font(designSystem.typography.title2)
                    .fontWeight(.bold)
                Text("Keep journaling to maintain your streak")
                    .font(designSystem.typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(designSystem.spacing.lg)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var weeklyStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: designSystem.spacing.md) {
            StatCard(title: "This Week", value: "\(weeklyEntries.count)", subtitle: "entries", icon: "calendar", color: designSystem.accentColor)
            StatCard(title: "Avg Mood", value: String(format: "%.1f", averageMood), subtitle: "out of 5", icon: "face.smiling", color: .orange)
            StatCard(title: "Total Insights", value: "\(insights.count)", subtitle: "generated", icon: "lightbulb.fill", color: .yellow)
            StatCard(title: "Acted On", value: "\(insights.filter(\.isActedOn).count)", subtitle: "insights", icon: "checkmark.circle.fill", color: .green)
        }
        .padding(.horizontal)
    }
    
    private var settingsSection: some View {
        VStack(spacing: designSystem.spacing.sm) {
            SettingsRow(icon: "paintbrush.fill", title: "Theme", color: .purple) {
                showingThemePicker = true
            }
            SettingsRow(icon: "lock.shield.fill", title: "Privacy", color: .blue) {
                showingPrivacySettings = true
            }
            SettingsRow(icon: "square.and.arrow.up.fill", title: "Export Journal", color: .green) {
                showingExport = true
            }
            SettingsRow(icon: "trash.fill", title: "Clear All Data", color: .red) {
                // Handle data clear
            }
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: designSystem.spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(designSystem.typography.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(designSystem.typography.headline)
            Text(subtitle)
                .font(designSystem.typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: designSystem.spacing.md) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundStyle(.white)
                            .font(.caption)
                    )
                Text(title)
                    .font(designSystem.typography.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct ThemePickerSheet: View {
    @Environment(\.designSystem) private var designSystem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                    Button {
                        designSystem.colorScheme = scheme
                        dismiss()
                    } label: {
                        HStack {
                            Circle()
                                .fill(scheme == .cosmic ? Color(red: 0.4, green: 0.3, blue: 1.0) :
                                      scheme == .aurora ? Color(red: 0.2, green: 0.8, blue: 0.6) :
                                      scheme == .sunset ? Color(red: 1.0, green: 0.4, blue: 0.2) :
                                      Color(red: 0.1, green: 0.5, blue: 0.9))
                                .frame(width: 24, height: 24)
                            Text(scheme.rawValue)
                                .font(.body)
                            Spacer()
                            if designSystem.colorScheme == scheme {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.designSystem, DesignSystem())
        .modelContainer(for: [JournalEntry.self, Insight.self], inMemory: true)
}
