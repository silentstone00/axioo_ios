import SwiftUI

// Screen-level view. Owns the ViewModel reference and wires
// action closures down to PitchCardView components.
struct FeedView: View {
    var vm: AppViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.pitches) { pitch in
                    PitchCardView(
                        pitch: pitch,
                        onLike: { vm.toggleLike(id: pitch.id) },
                        onSave: { vm.toggleSave(id: pitch.id) }
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.75)
                            .scaleEffect(phase.isIdentity ? 1 : 0.96)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
    }
}
