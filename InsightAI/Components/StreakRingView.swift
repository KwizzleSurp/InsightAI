import SwiftUI

struct StreakRingView: View {
    let streakDays: Int
    let nextMilestone: Int
    @Environment(\.designSystem) private var designSystem
    @State private var animatedProgress: Double = 0
    
    var progress: Double {
        min(Double(streakDays) / Double(nextMilestone), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: [designSystem.accentColor.opacity(0.5), designSystem.accentColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(streakDays)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(designSystem.accentColor)
                    Text("day streak")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            
            Text("Next: \(nextMilestone) days")
                .font(designSystem.typography.body)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                animatedProgress = progress
            }
        }
        .onChange(of: streakDays) { _, _ in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: streakDays)
    }
}

#Preview {
    StreakRingView(streakDays: 12, nextMilestone: 30)
        .environment(\.designSystem, DesignSystem())
        .padding()
}
