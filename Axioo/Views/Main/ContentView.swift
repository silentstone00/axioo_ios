import SwiftUI

// MARK: - App Tabs
enum AppTab: CaseIterable {
    case feed, bookmarks, profile

    var icon: String {
        switch self {
        case .feed:      return "play.fill"
        case .bookmarks: return "bookmark.fill"
        case .profile:   return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .feed:      return "FEED"
        case .bookmarks: return "SAVED"
        case .profile:   return "PROFILE"
        }
    }
}

// MARK: - Root View
struct ContentView: View {
    @State private var vm = AppViewModel()
    @State private var selectedTab: AppTab = .feed

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .feed:
                FeedView(vm: vm).ignoresSafeArea()
            case .bookmarks:
                BookmarksView(vm: vm)
            case .profile:
                ProfileView(vm: vm)
            }

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.axiooBlack)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    TabBarItem(icon: tab.icon, label: tab.label, isSelected: selectedTab == tab)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 8)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool

    @State private var scale: CGFloat = 1

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .scaleEffect(isSelected ? 1.15 : 1.0)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(isSelected ? Color.axiooOrange : .white.opacity(0.35))
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { scale = 1.2 }
                Task {
                    try? await Task.sleep(for: .milliseconds(200))
                    withAnimation(.spring(response: 0.3)) { scale = 1 }
                }
            }
        }
        .scaleEffect(scale)
    }
}
