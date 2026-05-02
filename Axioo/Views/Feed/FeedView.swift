import SwiftUI

struct FeedView: View {
    var vm: AppViewModel
    @State private var currentIndex = 0
    @State private var cache = PlayerCache()
    // One SwipeState per pitch — stable references shared between
    // UIKit gesture (in VideoFeedView) and SwiftUI view (PitchCardView).
    @State private var swipeStates = Pitch.sampleFeed.map { _ in SwipeState() }

    var body: some View {
        VideoFeedView(
            pitches:     vm.pitches,
            players:     cache.players,
            swipeStates: swipeStates,
            onLike:      { i in vm.toggleLike(id: vm.pitches[i].id) },
            onSave:      { i in vm.toggleSave(id: vm.pitches[i].id) },
            onSwipeLike: { i in vm.toggleLike(id: vm.pitches[i].id) },
            onSwipePass: { _ in },
            currentIndex: $currentIndex
        )
        .ignoresSafeArea()
        .onChange(of: currentIndex) { _, idx in warmAndPlay(around: idx) }
        .onChange(of: vm.videosPopulated) { _, ready in
            guard ready else { return }
            warmAndPlay(around: currentIndex)
        }
        .onAppear  { warmAndPlay(around: currentIndex) }
        .onDisappear { cache.pause(id: vm.pitches[currentIndex].id) }
    }

    private func warmAndPlay(around index: Int) {
        guard !vm.pitches.isEmpty else { return }
        cache.warmUp(pitches: vm.pitches, around: index)
        let id = vm.pitches[index].id
        cache.play(id: id)
        if index > 0 { cache.pause(id: vm.pitches[index - 1].id) }
        if index < vm.pitches.count - 1 { cache.pause(id: vm.pitches[index + 1].id) }
    }
}
