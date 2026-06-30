import SwiftUI

/// 收藏 tab — chapters the reader has bookmarked, in the order they were saved,
/// each linking back into the reader. Swipe to remove.
struct BookmarksView: View {
    @EnvironmentObject private var store: AppStore

    private var saved: [SutraChapter] {
        store.bookmarks.compactMap { id in Sutra.chapters.first { $0.id == id } }
    }

    var body: some View {
        NavigationStack {
            Group {
                if saved.isEmpty {
                    ContentUnavailableView {
                        Label("还没有收藏", systemImage: "bookmark")
                    } description: {
                        Text("在阅读某一分时，点击右上角的书签即可收藏。")
                    }
                } else {
                    List {
                        ForEach(saved) { chapter in
                            NavigationLink(value: chapter.id) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(chapter.fullTitle)
                                        .font(.headline).foregroundStyle(Theme.ink)
                                    Text(chapter.body)
                                        .font(.caption).foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Theme.card)
                        }
                        .onDelete { offsets in
                            for i in offsets { store.toggleBookmark(saved[i].id) }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.bg)
            .navigationTitle("收藏")
            .navigationDestination(for: Int.self) { id in
                if let chapter = Sutra.chapters.first(where: { $0.id == id }) {
                    ChapterDetailView(chapter: chapter)
                }
            }
        }
    }
}

#Preview {
    BookmarksView().environmentObject(AppStore.shared)
}
