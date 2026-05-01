import SwiftUI
import AVFoundation
import CoreMedia

// MARK: - Animated gradient fallback (shown while video loads)
struct AnimatedVideoBackground: View {
    let pitch: Pitch
    @State private var phase1 = false
    @State private var phase2 = false

    private var seed: Double { Double(abs(pitch.id.hashValue) % 1000) / 1000.0 }

    var body: some View {
        ZStack {
            Rectangle().fill(pitch.colors[0])

            Ellipse()
                .fill(pitch.colors.count > 1 ? pitch.colors[1] : pitch.colors[0])
                .frame(width: 380, height: 380)
                .blur(radius: 90)
                .offset(x: phase1 ? 80 : -80, y: phase1 ? -130 : -40)
                .opacity(0.7)

            Circle()
                .fill(pitch.colors.count > 2 ? pitch.colors[2] : pitch.colors[0])
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: phase2 ? -70 : 90, y: phase2 ? 170 : 60)
                .opacity(0.6)

            Circle()
                .fill(Color.axiooOrange.opacity(0.25))
                .frame(width: 160, height: 160)
                .blur(radius: 50)
                .offset(x: phase1 ? -110 : 60, y: phase1 ? 110 : -160)
                .opacity(0.5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.5 + seed * 2).repeatForever(autoreverses: true)) { phase1 = true }
            withAnimation(.easeInOut(duration: 6.0 + seed * 3).repeatForever(autoreverses: true)) { phase2 = true }
        }
    }
}

// MARK: - Background layer
struct PitchBackground: View {
    let pitch: Pitch
    let player: AVPlayer?

    var body: some View {
        ZStack {
            if player != nil {
                VideoPlayerLayer(player: player)
                    .ignoresSafeArea()
            } else {
                AnimatedVideoBackground(pitch: pitch)
            }

            // Text-readability gradient — always present regardless of source
            LinearGradient(
                colors: [
                    .clear, .clear,
                    Color.axiooBlack.opacity(0.3),
                    Color.axiooBlack.opacity(0.8),
                    Color.axiooBlack.opacity(0.97)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Video Progress Bar

private final class ProgressObserver {
    weak var player: AVPlayer?
    var token: Any?

    func start(player: AVPlayer, onUpdate: @escaping (CGFloat) -> Void) {
        stop()
        self.player = player
        token = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak player] time in
            guard let item = player?.currentItem,
                  item.duration.isValid, !item.duration.isIndefinite,
                  item.duration.seconds > 0 else { return }
            onUpdate(CGFloat(time.seconds / item.duration.seconds))
        }
    }

    func stop() {
        if let token, let player { player.removeTimeObserver(token) }
        token = nil
        player = nil
    }

    deinit { stop() }
}

struct VideoProgressBar: View {
    let player: AVPlayer?
    @State private var progress: CGFloat = 0
    @State private var obs = ProgressObserver()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.2)).frame(height: 2)
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: geo.size.width * progress, height: 2)
            }
        }
        .frame(height: 2)
        .onAppear   { if let p = player { obs.start(player: p) { progress = $0 } } }
        .onDisappear { obs.stop(); progress = 0 }
        .onChange(of: player) { _, newPlayer in
            if let p = newPlayer { obs.start(player: p) { progress = $0 } }
            else { obs.stop(); progress = 0 }
        }
    }
}

// MARK: - Action Button (right rail)
struct ActionButton: View {
    let systemImage: String
    let label: String
    let tintColor: Color
    let action: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        Button {
            action()
            withAnimation(.spring(response: 0.18, dampingFraction: 0.45)) {
                scale = 1.45; glowRadius = 14
            }
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    scale = 1.0; glowRadius = 0
                }
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(tintColor)
                    .scaleEffect(scale)
                    .shadow(color: tintColor.opacity(0.7), radius: glowRadius)
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pitch Card
struct PitchCardView: View {
    let pitch: Pitch
    let player: AVPlayer?
    let swipe: SwipeState     // offset + intensity driven by UIKit HorizontalOnlyPan
    let onLike: () -> Void
    let onSave: () -> Void

    var body: some View {
        ZStack {
            PitchBackground(pitch: pitch, player: player).ignoresSafeArea()

            // Top bar
            VStack(spacing: 0) {
                VideoProgressBar(player: player)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                HStack(spacing: 8) {
                    CategoryBadge(text: pitch.category)
                    if pitch.trendingScore >= 90 { TrendingBadge() }
                    Spacer()
                    if swipe.isPlaying2x {
                        Text("2×")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.white.opacity(0.18)))
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: swipe.isPlaying2x)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                Spacer()
            }

            // Bottom content
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pitch.startupName)
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                        Text(pitch.tagline)
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 6) {
                            Text(pitch.founderName).font(.system(size: 13, weight: .semibold))
                            Text("·")
                            Text(pitch.founderTitle).font(.system(size: 13))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        HStack(spacing: 8) {
                            StageBadge(stage: pitch.stage)
                            if let raised = pitch.raised {
                                HStack(spacing: 4) {
                                    Text("◆").font(.system(size: 7)).foregroundStyle(Color.axiooOrange)
                                    Text(raised)
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                        }
                        Text(pitch.locationTag.uppercased())
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.top, 2)
                    }

                    Spacer(minLength: 16)

                    VStack(spacing: 22) {
                        ActionButton(
                            systemImage: pitch.isLiked ? "heart.fill" : "heart",
                            label: formatMetric(pitch.likes),
                            tintColor: pitch.isLiked ? .axiooOrange : .white,
                            action: onLike
                        )
                        ActionButton(
                            systemImage: pitch.isSaved ? "bookmark.fill" : "bookmark",
                            label: formatMetric(pitch.saves),
                            tintColor: pitch.isSaved ? .axiooPurple : .white,
                            action: onSave
                        )
                        ActionButton(
                            systemImage: "eye",
                            label: formatMetric(pitch.views),
                            tintColor: .white.opacity(0.5),
                            action: {}
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 104)
            }

            // Swipe overlays — driven by swipe.intensity from UIKit gesture
            if swipe.intensity > 0.05 {
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        colors: [Color.axiooOrange.opacity(swipe.intensity * 0.5), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    LikeStamp()
                        .opacity(swipe.intensity)
                        .rotationEffect(.degrees(-12))
                        .padding(.top, 90).padding(.leading, 30)
                }
                .allowsHitTesting(false)
            }

            if swipe.intensity < -0.05 {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [.clear, .white.opacity(abs(swipe.intensity) * 0.15)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    PassStamp()
                        .opacity(abs(swipe.intensity))
                        .rotationEffect(.degrees(12))
                        .padding(.top, 90).padding(.trailing, 30)
                }
                .allowsHitTesting(false)
            }
        }
        .offset(x: swipe.offset)
        .rotationEffect(.degrees(swipe.offset / 28), anchor: .bottom)
    }
}
