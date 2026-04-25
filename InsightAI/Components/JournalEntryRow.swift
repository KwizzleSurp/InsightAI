import SwiftUI
import SwiftData

struct JournalEntryRow: View {
    let entry: JournalEntry
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: moodIcon)
                    .font(.title3)
                    .foregroundStyle(moodColor)
                Text("\(entry.mood)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                    .font(designSystem.typography.body)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                HStack {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    if entry.tags.count > 3 {
                        Text("+\(entry.tags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(relativeDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .insightCardStyle()
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
    }
    
    private var moodIcon: String {
        switch entry.mood {
        case 1, 2: return "face.frown"
        case 3: return "face.neutral"
        case 4, 5: return "face.smiling"
        default: return "face.dashed"
        }
    }
    
    private var moodColor: Color {
        switch entry.mood {
        case 1, 2: return .red
        case 3: return .orange
        case 4, 5: return .green
        default: return .gray
        }
    }
    
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: entry.date, relativeTo: Date())
    }
}

#Preview {
    JournalEntryRow(entry: JournalEntry(
        content: "Today was productive but exhausting. Meetings all day with great outcomes.",
        mood: 4, energy: 3, tags: ["work", "growth", "energy"]
    ))
    .environment(\.designSystem, DesignSystem())
    .padding()
}
