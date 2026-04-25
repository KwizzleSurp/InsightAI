import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let label: String
    let icon: String
    let range: ClosedRange<Double>
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(designSystem.accentColor)
                Text(label)
                    .font(designSystem.typography.headline)
                Spacer()
                Text("\(Int(value))")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(designSystem.accentColor)
            }
            
            Slider(value: $value, in: range, step: 1) { editing in
                if editing {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .tint(designSystem.accentColor)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CustomSlider(value: .constant(3), label: "Mood", icon: "face.smiling", range: 1...5)
        .environment(\.designSystem, DesignSystem())
        .padding()
        .previewLayout(.sizeThatFits)
}
