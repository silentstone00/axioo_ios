import SwiftUI
import Observation

@Observable
class AppViewModel {

    // MARK: - State
    private(set) var pitches: [Pitch] = Pitch.sampleFeed
    private(set) var videosPopulated = false

    var user = AppUser(
        name: "Aviral Saxena",
        handle: "@aviral",
        userType: .investor,
        bio: "Early-stage investor. Interested in AI, climate, and developer tools.",
        following: 47,
        portfolioCount: 12
    )

    // MARK: - Derived collections
    var savedPitches: [Pitch] { pitches.filter(\.isSaved) }
    var likedPitches: [Pitch] { pitches.filter(\.isLiked) }

    init() {
        Task { await fetchVideos() }
    }

    // MARK: - Video prefetch
    private func fetchVideos() async {
        let urls = await PexelsService.fetchPopularPortraitURLs(count: max(pitches.count, 15))
        guard !urls.isEmpty else { return }
        for i in pitches.indices {
            pitches[i].videoURL = urls[i % urls.count]
        }
        videosPopulated = true
    }

    // MARK: - Actions
    func toggleLike(id: UUID) {
        guard let i = pitches.firstIndex(where: { $0.id == id }) else { return }
        pitches[i].isLiked.toggle()
        pitches[i].likes += pitches[i].isLiked ? 1 : -1
    }

    func toggleSave(id: UUID) {
        guard let i = pitches.firstIndex(where: { $0.id == id }) else { return }
        pitches[i].isSaved.toggle()
        pitches[i].saves += pitches[i].isSaved ? 1 : -1
    }
}
