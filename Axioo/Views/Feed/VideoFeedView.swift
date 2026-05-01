import SwiftUI
import UIKit
import AVFoundation

// MARK: - SwiftUI wrapper
struct VideoFeedView: UIViewControllerRepresentable {
    let pitches:      [Pitch]
    let players:      [UUID: AVPlayer]
    let swipeStates:  [SwipeState]
    let onLike:       (Int) -> Void
    let onSave:       (Int) -> Void
    let onSwipeLike:  (Int) -> Void
    @Binding var currentIndex: Int

    func makeUIViewController(context: Context) -> VideoFeedViewController {
        VideoFeedViewController(
            pitches:      pitches,
            players:      players,
            swipeStates:  swipeStates,
            onLike:       onLike,
            onSave:       onSave,
            onSwipeLike:  onSwipeLike,
            onPageChange: { currentIndex = $0 }
        )
    }

    func updateUIViewController(_ vc: VideoFeedViewController, context: Context) {
        vc.refresh(pitches: pitches, players: players)
    }
}

// MARK: - View Controller
final class VideoFeedViewController: UIViewController,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegate {

    // MARK: State
    private var pitches:     [Pitch]
    private var players:     [UUID: AVPlayer]
    private let swipeStates: [SwipeState]
    private let onLike:      (Int) -> Void
    private let onSave:      (Int) -> Void
    private let onSwipeLike: (Int) -> Void
    private let onPageChange:(Int) -> Void

    // One UIHostingController per pitch — created once, reused across cell reuse cycles
    private var hostingControllers: [UIHostingController<PitchCardView>] = []

    private lazy var collectionView: PagingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection  = .vertical
        layout.minimumLineSpacing = 0
        let cv = PagingCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .black
        cv.bounces = false
        cv.dataSource = self
        cv.delegate   = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        return cv
    }()

    // MARK: Init
    init(pitches: [Pitch], players: [UUID: AVPlayer], swipeStates: [SwipeState],
         onLike: @escaping (Int) -> Void, onSave: @escaping (Int) -> Void,
         onSwipeLike: @escaping (Int) -> Void, onPageChange: @escaping (Int) -> Void) {
        self.pitches      = pitches
        self.players      = players
        self.swipeStates  = swipeStates
        self.onLike       = onLike
        self.onSave       = onSave
        self.onSwipeLike  = onSwipeLike
        self.onPageChange = onPageChange
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        buildHostingControllers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = view.bounds.size
    }

    // MARK: State updates from SwiftUI
    func refresh(pitches: [Pitch], players: [UUID: AVPlayer]) {
        self.pitches = pitches
        self.players = players
        for (i, hc) in hostingControllers.enumerated() where i < pitches.count {
            hc.rootView = pitchCardView(at: i)
        }
    }

    // MARK: Private helpers
    private func buildHostingControllers() {
        hostingControllers = pitches.indices.map { i in
            let hc = UIHostingController(rootView: pitchCardView(at: i))
            hc.view.backgroundColor = .clear
            addChild(hc)
            hc.didMove(toParent: self)
            return hc
        }
    }

    private func pitchCardView(at i: Int) -> PitchCardView {
        PitchCardView(
            pitch:  pitches[i],
            player: players[pitches[i].id],
            swipe:  swipeStates[i],
            onLike: { [weak self] in self?.onLike(i) },
            onSave: { [weak self] in self?.onSave(i) }
        )
    }

    private func animateSwipe(state: SwipeState, offset: CGFloat) {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { state.offset = offset }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                state.offset = 0; state.intensity = 0
            }
        }
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        pitches.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseID, for: ip) as! VideoCell
        let i = ip.item

        cell.host(view: hostingControllers[i].view)
        cell.attachInteraction(player: players[pitches[i].id], swipeState: swipeStates[i])
        cell.attachSwipe(
            state: swipeStates[i],
            onChanged: { tx, state in
                state.offset    = tx * 0.85
                state.intensity = min(1, abs(tx) / 110) * (tx > 0 ? 1 : -1)
            },
            onEnded: { [weak self] tx, vx, state in
                guard let self else { return }
                if tx > 80 || (tx > 30 && vx > 400) {
                    self.onSwipeLike(i)
                    self.animateSwipe(state: state, offset: 600)
                } else if tx < -80 || (tx < -30 && vx < -400) {
                    self.animateSwipe(state: state, offset: -600)
                } else {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        state.offset = 0; state.intensity = 0
                    }
                }
            }
        )
        return cell
    }

    // MARK: UIScrollViewDelegate (paging callback)
    func scrollViewDidEndDecelerating(_ sv: UIScrollView) {
        let page = Int(sv.contentOffset.y / max(sv.frame.height, 1))
        onPageChange(page)
    }
}

// MARK: - PagingCollectionView
// UICollectionView subclass so we can act as our own gesture delegate and
// allow simultaneous recognition with HorizontalOnlyPan on cells.
private final class PagingCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gr: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return other is UIPanGestureRecognizer
    }
}

// MARK: - VideoCell
private final class VideoCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static let reuseID = "VideoCell"

    private var pan:  HorizontalOnlyPan?
    private var tapGR: UITapGestureRecognizer?
    private var holdGR: UILongPressGestureRecognizer?

    private weak var player: AVPlayer?
    private var swipeState: SwipeState?
    private var wasPlayingBeforeHold = false

    private enum Zone { case left, center, right }
    private func zone(at point: CGPoint) -> Zone {
        let w = contentView.bounds.width
        if point.x < w * 0.25 { return .left }
        if point.x > w * 0.75 { return .right }
        return .center
    }

    // MARK: - Hosting

    func host(view: UIView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        view.frame = contentView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(view)
    }

    // MARK: - Swipe (horizontal like/pass)

    func attachSwipe(
        state: SwipeState,
        onChanged: @escaping (CGFloat, SwipeState) -> Void,
        onEnded:   @escaping (CGFloat, CGFloat, SwipeState) -> Void
    ) {
        if let old = pan { contentView.removeGestureRecognizer(old) }
        let p = HorizontalOnlyPan()
        p.onChanged = { tx in onChanged(tx, state) }
        p.onEnded   = { tx, vx in onEnded(tx, vx, state) }
        contentView.addGestureRecognizer(p)
        pan = p
    }

    // MARK: - Zone interaction (tap center = pause/resume, hold left/right = 2x)

    func attachInteraction(player: AVPlayer?, swipeState: SwipeState) {
        self.player = player
        self.swipeState = swipeState
        if let old = tapGR  { contentView.removeGestureRecognizer(old) }
        if let old = holdGR { contentView.removeGestureRecognizer(old) }

        let hold = UILongPressGestureRecognizer(target: self, action: #selector(handleHold))
        hold.minimumPressDuration = 0.2
        hold.delegate = self
        contentView.addGestureRecognizer(hold)
        holdGR = hold

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        contentView.addGestureRecognizer(tap)
        tapGR = tap
    }

    // Route each recognizer to its zone before it begins — avoids require(toFail:) delay.
    override func gestureRecognizerShouldBegin(_ gr: UIGestureRecognizer) -> Bool {
        let z = zone(at: gr.location(in: contentView))
        if gr === tapGR  { return z == .center }
        if gr === holdGR { return z != .center }
        return true
    }

    // Allow hold + HorizontalOnlyPan to fire simultaneously so a slight finger
    // drift during a hold doesn't cancel the 2x-speed state.
    func gestureRecognizer(_ gr: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return gr === holdGR && other is UIPanGestureRecognizer
    }

    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        guard let player else { return }
        player.timeControlStatus == .paused ? player.play() : player.pause()
    }

    @objc private func handleHold(_ gr: UILongPressGestureRecognizer) {
        guard let player else { return }
        switch gr.state {
        case .began:
            wasPlayingBeforeHold = player.timeControlStatus == .playing
            if wasPlayingBeforeHold { player.rate = 2.0; swipeState?.isPlaying2x = true }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .ended, .cancelled, .failed:
            if wasPlayingBeforeHold { player.rate = 1.0 }
            swipeState?.isPlaying2x = false
            wasPlayingBeforeHold = false
        default: break
        }
    }
}

// MARK: - HorizontalOnlyPan
// Self-cancels on vertical movement so UICollectionView can page;
// agrees to share the touch for simultaneous recognition.
private final class HorizontalOnlyPan: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    var onChanged: ((CGFloat) -> Void)?
    var onEnded:   ((CGFloat, CGFloat) -> Void)?

    init() {
        super.init(target: nil, action: nil)
        delegate = self
        maximumNumberOfTouches = 1
        addTarget(self, action: #selector(handle))
    }

    @objc private func handle() {
        let tx = translation(in: view).x
        switch state {
        case .changed: onChanged?(tx)
        case .ended, .cancelled: onEnded?(tx, velocity(in: view).x)
        default: break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let v = velocity(in: view)
            if abs(v.y) > abs(v.x) { state = .failed }
        }
    }

    func gestureRecognizer(_ gr: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
}
