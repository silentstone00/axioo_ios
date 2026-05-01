import SwiftUI

// MARK: - Screen
struct ProfileView: View {
    var vm: AppViewModel
    @State private var section: ProfileSection = .saved

    enum ProfileSection: String, CaseIterable {
        case saved = "SAVED"
        case liked = "LIKED"
    }

    var activePitches: [Pitch] {
        section == .saved ? vm.savedPitches : vm.likedPitches
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.axiooBlack.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        UserCardView(user: vm.user)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        StatsRow(
                            liked: vm.likedPitches.count,
                            saved: vm.savedPitches.count,
                            following: vm.user.following,
                            portfolio: vm.user.portfolioCount
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        SectionPicker(selected: $section)
                            .padding(.horizontal, 20)
                            .padding(.top, 28)

                        if activePitches.isEmpty {
                            ProfileEmptyState(section: section)
                                .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 1) {
                                ForEach(activePitches) { pitch in
                                    ProfilePitchRow(
                                        pitch: pitch,
                                        section: section,
                                        onRemove: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                section == .saved
                                                    ? vm.toggleSave(id: pitch.id)
                                                    : vm.toggleLike(id: pitch.id)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.top, 16)
                        }

                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("AXIOO")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.axiooCream)
                        .kerning(4)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Components
// Each component receives only the data it needs — no ViewModel dependency.

struct UserCardView: View {
    let user: AppUser

    private var initials: String {
        user.name.split(separator: " ").compactMap(\.first).prefix(2).map(String.init).joined()
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.axiooPurple, Color.axiooOrange],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                Text(initials)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(user.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.axiooCream)
                    UserTypeBadge(type: user.userType)
                }
                Text(user.handle)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.45))
                Text(user.bio)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
    }
}

struct UserTypeBadge: View {
    let type: AppUser.UserType
    var color: Color {
        switch type {
        case .investor: return .axiooOrange
        case .founder:  return .axiooPurple
        case .scout:    return .white.opacity(0.6)
        }
    }
    var body: some View {
        Text(type.rawValue.uppercased())
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct StatsRow: View {
    let liked: Int
    let saved: Int
    let following: Int
    let portfolio: Int

    var body: some View {
        HStack(spacing: 0) {
            StatCell(value: liked,     label: "LIKED")
            Divider().frame(width: 1, height: 32).background(.white.opacity(0.1))
            StatCell(value: saved,     label: "SAVED")
            Divider().frame(width: 1, height: 32).background(.white.opacity(0.1))
            StatCell(value: following, label: "FOLLOWING")
            Divider().frame(width: 1, height: 32).background(.white.opacity(0.1))
            StatCell(value: portfolio, label: "PORTFOLIO")
        }
        .padding(.vertical, 20)
        .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

struct StatCell: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.axiooCream)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionPicker: View {
    @Binding var selected: ProfileView.ProfileSection

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileView.ProfileSection.allCases, id: \.self) { s in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selected = s }
                } label: {
                    VStack(spacing: 6) {
                        Text(s.rawValue)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(selected == s ? Color.axiooCream : .white.opacity(0.35))
                        Rectangle()
                            .fill(selected == s ? Color.axiooOrange : .clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ProfilePitchRow: View {
    let pitch: Pitch
    let section: ProfileView.ProfileSection
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: pitch.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(pitch.colors[0])
                }
            }
            .frame(width: 72, height: 72)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(pitch.startupName)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.axiooCream)
                    StageBadge(stage: pitch.stage)
                }
                Text(pitch.tagline)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    Label(formatMetric(pitch.likes), systemImage: "heart.fill")
                    Label(formatMetric(pitch.views), systemImage: "eye")
                }
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.35))
                .labelStyle(.titleAndIcon)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: section == .saved ? "bookmark.fill" : "heart.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(section == .saved ? Color.axiooPurple : Color.axiooOrange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.03))
    }
}

struct ProfileEmptyState: View {
    let section: ProfileView.ProfileSection
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: section == .saved ? "bookmark" : "heart")
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(.white.opacity(0.15))
            Text("NO \(section.rawValue) PITCHES")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}
