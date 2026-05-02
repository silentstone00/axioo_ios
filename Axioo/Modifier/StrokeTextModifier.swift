
import SwiftUI

// MARK: - Stroke Text Modifier

struct StrokeTextModifier: ViewModifier {
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let fontDesign: Font.Design
    let textColor: Color
    let strokeColor: Color
    let strokeWidth: CGFloat
    let quality: StrokeQuality
    
    enum StrokeQuality {
        case low, medium, high
        var sampleCount: Int {
            switch self {
            case .low: return 8
            case .medium: return 16
            case .high: return 32
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            // Stroke layers — drawn first, behind
            ForEach(0..<quality.sampleCount, id: \.self) { i in
                let angle = Double(i) * (2 * .pi) / Double(quality.sampleCount)
                content
                    .font(.system(size: fontSize, weight: fontWeight, design: fontDesign))
                    .foregroundColor(strokeColor)
                    .offset(
                        x: cos(angle) * strokeWidth,
                        y: sin(angle) * strokeWidth
                    )
            }
            
            // Main text on top
            content
                .font(.system(size: fontSize, weight: fontWeight, design: fontDesign))
                .foregroundColor(textColor)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Styles text with a stroke/outline. Configures font and stroke together.
    ///
    /// - Parameters:
    ///   - size: Font size in points
    ///   - weight: Font weight
    ///   - design: Font design
    ///   - textColor: Fill color of the text
    ///   - strokeColor: Color of the stroke outline
    ///   - strokeWidth: Width of the stroke in points
    ///   - quality: Smoothness of the stroke (default: .medium)
    func strokedText(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        textColor: Color,
        strokeColor: Color,
        strokeWidth: CGFloat = 1,
        quality: StrokeTextModifier.StrokeQuality = .medium
    ) -> some View {
        self.modifier(
            StrokeTextModifier(
                fontSize: size,
                fontWeight: weight,
                fontDesign: design,
                textColor: textColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                quality: quality
            )
        )
    }
}
