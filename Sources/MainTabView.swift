import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView {
            SutraHomeView()
                .tabItem { Label("经文", systemImage: "book.fill") }
            ReciteView()
                .tabItem { Label("持诵", systemImage: "hand.tap.fill") }
            BookmarksView()
                .tabItem { Label("收藏", systemImage: "bookmark.fill") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
            AboutView()
                .tabItem { Label("关于", systemImage: "info.circle.fill") }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    MainTabView().environmentObject(AppStore.shared)
}
