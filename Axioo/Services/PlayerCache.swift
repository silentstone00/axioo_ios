import AVFoundation
import Observation

// Sliding window of AVPlayer instances — 1 behind, current, 2 ahead.
// Players outside the window are paused and released to free memory.
@Observable
final class PlayerCache {

    private(set) var players: [UUID: AVPlayer] = [:]
    private let windowSize = 3

    // MARK: - Window management
    func warmUp(pitches: [Pitch], around index: Int) {
        let lo = max(0, index - 1)
        let hi = min(pitches.count - 1, index + windowSize)

        // Create players for the window
        for i in lo ... hi {
            let pitch = pitches[i]
            guard let url = pitch.videoURL, players[pitch.id] == nil else { continue }
            players[pitch.id] = makePlayer(url: url)
        }

        // Release players outside the window to free memory
        let active = Set(pitches[lo ... hi].map(\.id))
        for id in players.keys where !active.contains(id) {
            players[id]?.pause()
            players.removeValue(forKey: id)
        }
    }

    // MARK: - Playback control
    func play(id: UUID) {
        players[id]?.play()
    }

    func pause(id: UUID) {
        players[id]?.pause()
    }

    // MARK: - Private
    private func makePlayer(url: URL) -> AVPlayer {
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.play()
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in p.seek(to: .zero); p.play() }
        return p
    }
}
