import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SutraHomeView()
                .tabItem { Label("经文", systemImage: "book.fill") }
            FeedbackView()
                .tabItem { Label("反馈", systemImage: "bubble.left.and.bubble.right.fill") }
            AboutView()
                .tabItem { Label("关于", systemImage: "info.circle.fill") }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    MainTabView()
}
