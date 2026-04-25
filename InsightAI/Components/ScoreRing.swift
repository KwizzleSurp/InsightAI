//
//  ScoreRing.swift
//  InsightAI
//

import SwiftUI

struct ScoreRing: View {
    let score: Double  // 0.0 ... 1.0
    @Environment(\.designSystem) private var designSystem
    @State private var animatedScore: Double = 0
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: 4)
            
            // Progress Arc
            Circle()
                .trim(from: 0, to: animatedScore)
                .stroke(
                    ringGradient,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: animatedScore)
            
            // Score Label
            Text("\(Int(score * 100))")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(ringColor)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8).delay(0.1)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(duration: 0.6)) {
                animatedScore = newValue
            }
        }
    }
    
    private var ringColor: Color {
        if score >= 0.75 { return .green }
        if score >= 0.5 { return designSystem.accentColor }
        return .orange
    }
    
    private var trackColor: Color {
        ringColor.opacity(0.15)
    }
    
    private var ringGradient: AngularGradient {
        AngularGradient(
            colors: [ringColor.opacity(0.5), ringColor],
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }
}

#Preview {
    HStack(spacing: 20) {
        ScoreRing(score: 0.87).frame(width: 56, height: 56)
        ScoreRing(score: 0.62).frame(width: 56, height: 56)
        ScoreRing(score: 0.35).frame(width: 56, height: 56)
    }
    .environment(\.designSystem, DesignSystem())
    .padding()
}
