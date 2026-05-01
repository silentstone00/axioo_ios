import AVFoundation
import Observation

// Sliding window of AVPlayer instances — 1 behind, current, 2 ahead.
// Players outside the window are paused and released to free memory.
@Observable
final class PlayerCache {

    private(set) var players: [UUID: AVPlayer] = [:]
    private var loopTokens:   [UUID: NSObjectProtocol] = [:]
    private let windowSize = 3

    // MARK: - Window management
    func warmUp(pitches: [Pitch], around index: Int) {
        let lo = max(0, index - 1)
        let hi = min(pitches.count - 1, index + windowSize)

        for i in lo ... hi {
            let pitch = pitches[i]
            guard let url = pitch.videoURL, players[pitch.id] == nil else { continue }
            players[pitch.id] = makePlayer(url: url, id: pitch.id)
        }

        let active = Set(pitches[lo ... hi].map(\.id))
        for id in players.keys where !active.contains(id) {
            players[id]?.pause()
            players.removeValue(forKey: id)
            if let token = loopTokens.removeValue(forKey: id) {
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    // MARK: - Playback control
    func play(id: UUID)  { players[id]?.play() }
    func pause(id: UUID) { players[id]?.pause() }

    // MARK: - Private
    private func makePlayer(url: URL, id: UUID) -> AVPlayer {
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.play()
        let token = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak p] _ in p?.seek(to: .zero); p?.play() }
        loopTokens[id] = token
        return p
    }
}
