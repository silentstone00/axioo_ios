import SwiftUI

// MARK: - Screen
struct BookmarksView: View {
  var vm: AppViewModel

  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12),
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        Color.axiooBlack.ignoresSafeArea()

        if vm.savedPitches.isEmpty {
          BookmarksEmptyState()
        } else {
          ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
              ForEach(vm.savedPitches) { pitch in
                BookmarkCard(
                  pitch: pitch,
                  onUnsave: { vm.toggleSave(id: pitch.id) }
                )
              }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack(spacing: 6) {
            Text("SAVED")
              .font(.system(size: 13, weight: .bold, design: .monospaced))
              .foregroundStyle(Color.axiooCream)
            Text("·").foregroundStyle(.white.opacity(0.3))
            Text("\(vm.savedPitches.count)")
              .font(.system(size: 13, weight: .bold, design: .monospaced))
              .foregroundStyle(Color.axiooPurple)
          }
        }
      }
    }
    .preferredColorScheme(.dark)
  }
}

// MARK: - Component
// Receives data + callback — no ViewModel dependency.
struct BookmarkCard: View {
  let pitch: Pitch
  let onUnsave: () -> Void

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      Rectangle()
        .fill(pitch.colors.first ?? .gray)
        .overlay(
          AsyncImage(url: pitch.thumbnailURL) { phase in
            if case .success(let img) = phase {
              img.resizable().scaledToFill()
            }
          }
        )
        .clipped()

      LinearGradient(
        colors: [.clear, Color.axiooBlack.opacity(0.85)],
        startPoint: .top,
        endPoint: .bottom
      )

      VStack(alignment: .leading, spacing: 4) {
        StageBadge(stage: pitch.stage)

        Text(pitch.startupName)
          .font(.system(size: 20, weight: .heavy))
          .foregroundStyle(.white)

        Text(pitch.tagline)
          .font(.system(size: 11))
          .foregroundStyle(.white.opacity(0.7))
          .lineLimit(2)

        HStack(spacing: 4) {
          Image(systemName: "heart.fill")
            .font(.system(size: 9))
            .foregroundStyle(.red)

          Text(formatMetric(pitch.likes))
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.6))

          Spacer()

          Button {
            onUnsave()
          } label: {
            Image(systemName: "bookmark.fill")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(Color.axiooPurple)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(12)
    }
    .frame(height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

// MARK: - Empty State
struct BookmarksEmptyState: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "bookmark")
        .font(.system(size: 40, weight: .thin))
        .foregroundStyle(.white.opacity(0.2))
      VStack(spacing: 6) {
        Text("NO SAVED PITCHES")
          .font(.system(size: 13, weight: .bold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.4))
        Text("Bookmark pitches from the feed\nto review them later.")
          .font(.system(size: 13))
          .foregroundStyle(.white.opacity(0.25))
          .multilineTextAlignment(.center)
      }
    }
  }
}
