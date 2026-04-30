import AVFoundation
import SwiftUI
import UIKit

// A UIViewRepresentable that renders an AVPlayer using AVPlayerLayer directly.
// Unlike VideoPlayer (AVPlayerViewController), this installs ZERO gesture
// recognizers, so swipe gestures on parent views are never intercepted.
struct VideoPlayerLayer: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> _PlayerLayerView {
        let view = _PlayerLayerView()
        view.playerLayer.videoGravity = .resizeAspectFill
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: _PlayerLayerView, context: Context) {
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
        }
    }
}

final class _PlayerLayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    required init?(coder: NSCoder) { fatalError() }
}
