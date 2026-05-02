import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let axiooOrange = Color(hex: "FE572A")
    static let axiooPurple = Color(hex: "685BC7")
    static let axiooCream  = Color(hex: "F3F0EB")
    static let axiooBlack  = Color(hex: "201E1F")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Metric Formatting
func formatMetric(_ n: Int) -> String {
    if n >= 1_000_000 {
        let v = Double(n) / 1_000_000
        return v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))M" : String(format: "%.1fM", v)
    }
    if n >= 1_000 {
        let v = Double(n) / 1_000
        return v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))K" : String(format: "%.1fK", v)
    }
    return "\(n)"
}

// MARK: - Shared Badge Components
struct CategoryBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
    }
}

struct TrendingBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 8, weight: .bold))
            Text("TRENDING")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(Color.axiooOrange)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.axiooOrange.opacity(0.15))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.axiooOrange.opacity(0.4), lineWidth: 0.5))
    }
}

struct StageBadge: View {
    let stage: String
    var accent: Color {
        switch stage {
        case "Series A": return .axiooOrange
        case "Seed":     return .axiooPurple
        default:         return .white.opacity(0.5)
        }
    }
    var body: some View {
        Text(stage.uppercased())
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundStyle(accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(accent.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - Swipe Stamps
struct LikeStamp: View {
    var body: some View {
        Text("LIKE")
            .font(.system(size: 30, weight: .heavy, design: .monospaced))
            .foregroundStyle(Color.red)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(Rectangle().strokeBorder(Color.red, lineWidth: 2.5))
    }
}

struct PassStamp: View {
    var body: some View {
        Text("PASS")
            .font(.system(size: 30, weight: .heavy, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(Rectangle().strokeBorder(.white, lineWidth: 2.5))
    }
}
