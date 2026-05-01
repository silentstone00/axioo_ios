import Observation
import CoreGraphics

/// Observable bridge between UIKit gesture recognizer (in VerticalPager)
/// and SwiftUI view state (in PitchCardView). One instance per page.
@Observable final class SwipeState {
    var offset: CGFloat = 0
    var intensity: CGFloat = 0
    var isPlaying2x: Bool = false
}
