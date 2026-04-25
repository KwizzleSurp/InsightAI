//
//  DesignSystem.swift
//  InsightAI
//

import SwiftUI

// MARK: - DesignSystem Environment Key
struct DesignSystemKey: EnvironmentKey {
    static let defaultValue = DesignSystem()
}

extension EnvironmentValues {
    var designSystem: DesignSystem {
        get { self[DesignSystemKey.self] }
        set { self[DesignSystemKey.self] = newValue }
    }
}

// MARK: - DesignSystem
@Observable
class DesignSystem {
    var colorScheme: AppColorScheme = .cosmic
    
    var accentColor: Color {
        switch colorScheme {
        case .cosmic: return Color(red: 0.4, green: 0.3, blue: 1.0)
        case .aurora: return Color(red: 0.2, green: 0.8, blue: 0.6)
        case .sunset: return Color(red: 1.0, green: 0.4, blue: 0.2)
        case .ocean: return Color(red: 0.1, green: 0.5, blue: 0.9)
        }
    }
    
    var typography: Typography { Typography() }
    var spacing: Spacing { Spacing() }
}

enum AppColorScheme: String, CaseIterable {
    case cosmic = "Cosmic"
    case aurora = "Aurora"
    case sunset = "Sunset"
    case ocean = "Ocean"
}

struct Typography {
    let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    let title = Font.system(.title, design: .rounded, weight: .semibold)
    let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
    let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    let body = Font.system(.body, design: .rounded)
    let caption = Font.system(.caption, design: .rounded)
    let caption2 = Font.system(.caption2, design: .rounded)
}

struct Spacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
}

// MARK: - ViewModifiers
extension View {
    func insightCardStyle() -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
