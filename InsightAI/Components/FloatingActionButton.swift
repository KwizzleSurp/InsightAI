import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(designSystem.accentColor)
                .clipShape(Circle())
                .shadow(color: designSystem.accentColor.opacity(0.3), radius: 20, x: 0, y: 8)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: true)
        .accessibilityLabel("Create new journal entry")
        .accessibilityHint("Double tap to create a new journal entry")
    }
}

#Preview {
    FloatingActionButton {}
        .environment(\.designSystem, DesignSystem())
        .padding()
}
