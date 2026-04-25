import SwiftUI

struct VoiceWaveformStub: View {
    @State private var isRecording = false
    @State private var phase: CGFloat = 0
    @Environment(\.designSystem) private var designSystem
    
    var body: some View {
        VStack(spacing: 12) {
            Text(isRecording ? "Recording..." : "Tap to record voice note")
                .font(.caption.weight(.medium))
                .foregroundStyle(isRecording ? .red : .secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<12, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isRecording ? Color.red.opacity(0.8) : Color.secondary.opacity(0.4))
                        .frame(width: 4, height: barHeight(for: index))
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.05), value: isRecording)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Button(action: toggleRecording) {
                Circle()
                    .fill(isRecording ? Color.red : designSystem.accentColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    )
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: isRecording)
            .accessibilityLabel(isRecording ? "Stop recording" : "Start voice recording")
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }
    
    private func toggleRecording() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isRecording.toggle()
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeights: [CGFloat] = [12, 20, 16, 28, 24, 32, 20, 24, 18, 30, 14, 22]
        let base = baseHeights[index % baseHeights.count]
        return isRecording ? base * (0.5 + abs(sin(phase * .pi + CGFloat(index) * 0.5)) * 0.5) : base * 0.3
    }
}

#Preview {
    VoiceWaveformStub()
        .environment(\.designSystem, DesignSystem())
        .padding()
}
