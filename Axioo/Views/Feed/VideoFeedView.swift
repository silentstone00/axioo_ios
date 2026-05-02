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
    let onSwipePass:  (Int) -> Void
    @Binding var currentIndex: Int

    func makeUIViewController(context: Context) -> VideoFeedViewController {
        VideoFeedViewController(
            pitches:      pitches,
            players:      players,
            swipeStates:  swipeStates,
            onLike:       onLike,
            onSave:       onSave,
            onSwipeLike:  onSwipeLike,
            onSwipePass:  onSwipePass,
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
    private let onSwipePass: (Int) -> Void
    private let onPageChange:(Int) -> Void

    // One UIHostingController per pitch — created once, reused across cell reuse cycles
    private var hostingControllers: [UIHostingController<PitchCardView>] = []

    private lazy var collectionView: PagingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection    = .vertical
        layout.minimumLineSpacing = 0
        let cv = PagingCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = UIColor(Color.axiooBlack)
        cv.bounces = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.dataSource = self
        cv.delegate   = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        return cv
    }()

    // MARK: Init
    init(pitches: [Pitch], players: [UUID: AVPlayer], swipeStates: [SwipeState],
         onLike: @escaping (Int) -> Void, onSave: @escaping (Int) -> Void,
         onSwipeLike: @escaping (Int) -> Void, onSwipePass: @escaping (Int) -> Void,
         onPageChange: @escaping (Int) -> Void) {
        self.pitches      = pitches
        self.players      = players
        self.swipeStates  = swipeStates
        self.onLike       = onLike
        self.onSave       = onSave
        self.onSwipeLike  = onSwipeLike
        self.onSwipePass  = onSwipePass
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
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = view.bounds.size
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
        // Cells that were dequeued before players loaded have player = nil.
        // Push the real player into them now so tap/hold interactions work.
        for cell in collectionView.visibleCells {
            guard let ip = collectionView.indexPath(for: cell) as IndexPath?,
                  let vc = cell as? VideoCell else { continue }
            let i = ip.item
            vc.attachInteraction(player: players[pitches[i].id], swipeState: swipeStates[i])
        }
    }

    // MARK: Private helpers
    private func buildHostingControllers() {
        hostingControllers = pitches.indices.map { i in
            let hc = UIHostingController(rootView: pitchCardView(at: i))
            // Don't let the hosting controller impose its own safe area — SwiftUI's
            // .ignoresSafeArea() calls handle that. Without this, the first cell
            // computes zero safe area insets (VC not yet in window at viewDidLoad time)
            // and leaves a black gap under the status bar that only clears after a swipe.
            hc.safeAreaRegions = []
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
        let direction: CGFloat = offset > 0 ? 1 : -1
        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
            state.offset = direction * 100
        } completion: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
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
                let raw = tx * 0.85
                // Cap visual travel to ±100 pt — keeps black area minimal
                state.offset    = raw > 0 ? min(100, raw) : max(-100, raw)
                state.intensity = min(1, abs(tx) / 110) * (tx > 0 ? 1 : -1)
            },
            onEnded: { [weak self] tx, vx, state in
                guard let self else { return }
                if tx > 30 && vx > 400 {
                    self.onSwipeLike(i)
                    self.animateSwipe(state: state, offset: 600)
                } else if tx < -30 && vx < -400 {
                    self.onSwipePass(i)
                    self.animateSwipe(state: state, offset: -600)
                } else {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                        state.offset = 0; state.intensity = 0
                    }
                }
            }
        )
        return cell
    }

    // MARK: UIScrollViewDelegate (paging callback)

    // Fire early — at 50% scroll — so PlayerCache warms up before the card is fully visible.
    private var lastReportedPage = 0
    func scrollViewDidScroll(_ sv: UIScrollView) {
        let h = max(sv.frame.height, 1)
        let page = min(pitches.count - 1, max(0, Int((sv.contentOffset.y + h * 0.5) / h)))
        if page != lastReportedPage {
            lastReportedPage = page
            onPageChange(page)
        }
    }

    func scrollViewDidEndDecelerating(_ sv: UIScrollView) {
        let page = Int(sv.contentOffset.y / max(sv.frame.height, 1))
        if page != lastReportedPage {
            lastReportedPage = page
            onPageChange(page)
        }
    }
}

// MARK: - SwipeLabelView
// Sits behind the card in the axiooBlack area. Stationary — the card slides over it.
private struct SwipeLabelView: View {
    let swipe: SwipeState

    private var likeConfirmed: Bool { swipe.intensity >= 0.99 }
    private var passConfirmed: Bool { swipe.intensity <= -0.99 }

    var body: some View {
        VStack {
            HStack {
                Text("LIKE")
                    .strokedText(
                        size: 52,
                        weight: .black,
                        textColor: likeConfirmed ? .axiooOrange : .axiooBlack,
                        strokeColor: .axiooOrange,
                        strokeWidth: 1
                    )
                    .rotationEffect(.degrees(-90))
                    .opacity(Double(max(0, swipe.intensity)))
                    .animation(.easeInOut(duration: 0.2), value: likeConfirmed)
                Spacer()

                Text("PASS")
                    .strokedText(
                        size: 52,
                        weight: .black,
                        textColor: passConfirmed ? .axiooBlack : .axiooPurple,
                        strokeColor: .axiooPurple,
                        strokeWidth: 1
                    )
                    .rotationEffect(.degrees(90))
                    .opacity(Double(max(0, -swipe.intensity)))
                    .animation(.easeInOut(duration: 0.2), value: passConfirmed)
            }
            .padding(.horizontal, 8)
            Spacer()
        }
        .padding(.top, 220)
    }
}

// MARK: - PagingCollectionView
// UICollectionView subclass so we can act as our own gesture delegate and
// allow simultaneous recognition with HorizontalOnlyPan on cells.
private final class PagingCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gr: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        return other is HorizontalOnlyPan
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

    private var labelVC: UIHostingController<SwipeLabelView>?

    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    private enum Zone { case left, center, right }
    private func zone(at point: CGPoint) -> Zone {
        let w = contentView.bounds.width
        if point.x < w * 0.25 { return .left }
        if point.x > w * 0.75 { return .right }
        return .center
    }

    // MARK: - Hosting

    func host(view: UIView) {
        // Remove previous card but keep the label view behind
        contentView.subviews
            .filter { $0 !== labelVC?.view }
            .forEach { $0.removeFromSuperview() }
        view.frame = contentView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(view) // card on top of labels
    }

    // MARK: - Swipe (horizontal like/pass)

    func attachSwipe(
        state: SwipeState,
        onChanged: @escaping (CGFloat, SwipeState) -> Void,
        onEnded:   @escaping (CGFloat, CGFloat, SwipeState) -> Void
    ) {
        // Create label view once; on cell reuse update the swipe reference
        if let existing = labelVC {
            existing.rootView = SwipeLabelView(swipe: state)
        } else {
            let vc = UIHostingController(rootView: SwipeLabelView(swipe: state))
            vc.safeAreaRegions = []
            vc.view.backgroundColor = .clear
            vc.view.isUserInteractionEnabled = false
            vc.view.frame = contentView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.insertSubview(vc.view, at: 0) // behind the card
            labelVC = vc
        }

        if let old = pan { contentView.removeGestureRecognizer(old) }
        var hapticFired = false
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        let p = HorizontalOnlyPan()
        p.onChanged = { tx in
            onChanged(tx, state)
            let intensity = state.intensity
            if abs(intensity) >= 0.99 && !hapticFired {
                haptic.impactOccurred()
                hapticFired = true
            } else if abs(intensity) < 0.99 {
                hapticFired = false
            }
        }
        p.onEnded = { tx, vx in
            onEnded(tx, vx, state)
            hapticFired = false
        }
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
