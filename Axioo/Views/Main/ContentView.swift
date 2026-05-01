import SwiftUI

struct ContentView: View {
    @State private var vm = AppViewModel()

    var body: some View {
        TabView {
            FeedView(vm: vm)
                .ignoresSafeArea()
                .tabItem {
                    Label("Feed", systemImage: "play.fill")
                }

            BookmarksView(vm: vm)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            ProfileView(vm: vm)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color.axiooOrange)
        .preferredColorScheme(.dark)
    }
}
