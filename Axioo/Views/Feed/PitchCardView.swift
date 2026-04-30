import SwiftUI

// MARK: - Animated Video Background
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

            LinearGradient(
                colors: [
                    .clear, .clear,
                    Color.axiooBlack.opacity(0.3),
                    Color.axiooBlack.opacity(0.8),
                    Color.axiooBlack.opacity(0.97)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.5 + seed * 2).repeatForever(autoreverses: true)) { phase1 = true }
            withAnimation(.easeInOut(duration: 6.0 + seed * 3).repeatForever(autoreverses: true)) { phase2 = true }
        }
    }
}

// MARK: - Video Progress Bar
struct VideoProgressBar: View {
    let durationSeconds: Int
    @State private var progress: CGFloat = 0

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
        .onAppear {
            withAnimation(.linear(duration: Double(durationSeconds))) { progress = 1.0 }
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
// Pure presentation component — receives data and action callbacks.
// Has no knowledge of AppViewModel.
struct PitchCardView: View {
    let pitch: Pitch
    let onLike: () -> Void
    let onSave: () -> Void

    @State private var swipeOffset: CGFloat = 0
    @State private var swipeIntensity: CGFloat = 0

    var body: some View {
        ZStack {
            AnimatedVideoBackground(pitch: pitch).ignoresSafeArea()

            // Top bar
            VStack(spacing: 0) {
                VideoProgressBar(durationSeconds: pitch.durationSeconds)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                HStack(spacing: 8) {
                    CategoryBadge(text: pitch.category)
                    if pitch.trendingScore >= 90 { TrendingBadge() }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                Spacer()
            }

            // Bottom content
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    // Startup info (left)
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

                    // Action rail (right)
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

            // Swipe overlays
            if swipeIntensity > 0.05 {
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        colors: [Color.axiooOrange.opacity(Double(swipeIntensity) * 0.5), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    LikeStamp()
                        .opacity(Double(swipeIntensity))
                        .rotationEffect(.degrees(-12))
                        .padding(.top, 90).padding(.leading, 30)
                }
                .allowsHitTesting(false)
            }

            if swipeIntensity < -0.05 {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [.clear, .white.opacity(Double(abs(swipeIntensity)) * 0.15)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    PassStamp()
                        .opacity(Double(abs(swipeIntensity)))
                        .rotationEffect(.degrees(12))
                        .padding(.top, 90).padding(.trailing, 30)
                }
                .allowsHitTesting(false)
            }
        }
        .offset(x: swipeOffset)
        .rotationEffect(.degrees(Double(swipeOffset) / 28), anchor: .bottom)
        .gesture(swipeGesture)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: swipeOffset)
    }

    // MARK: - Gesture handling (presentation logic only)
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                let dx = abs(value.translation.width)
                let dy = abs(value.translation.height)
                guard dx > dy * 0.8 else { return }
                swipeOffset    = value.translation.width * 0.85
                swipeIntensity = min(1, dx / 110) * (value.translation.width > 0 ? 1 : -1)
            }
            .onEnded { value in
                let dx = abs(value.translation.width)
                let dy = abs(value.translation.height)
                guard dx > dy * 0.8 else { resetSwipe(); return }
                if      value.translation.width >  90 { triggerLike() }
                else if value.translation.width < -90 { triggerPass() }
                else                                   { resetSwipe() }
            }
    }

    private func triggerLike() {
        onLike()
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { swipeOffset = 100 }
        Task {
            try? await Task.sleep(for: .milliseconds(160))
            resetSwipe()
        }
    }

    private func triggerPass() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) { swipeOffset = -100 }
        Task {
            try? await Task.sleep(for: .milliseconds(160))
            resetSwipe()
        }
    }

    private func resetSwipe() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            swipeOffset = 0; swipeIntensity = 0
        }
    }
}
