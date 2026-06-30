import SwiftUI

/// Home tab — daily verse, reading-progress, full-text search, and the list of
/// 32 分 with per-chapter read indicators.
struct SutraHomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""

    private var hits: [Sutra.SearchHit] { Sutra.search(query) }
    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isSearching {
                    searchResults
                } else {
                    browseContent
                }
            }
            .background(Theme.bg)
            .navigationTitle("金刚经")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "搜索经文")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: -1) {
                        Label("全文", systemImage: "text.justify")
                    }
                }
            }
            .navigationDestination(for: Int.self) { id in
                if id == -1 {
                    FullTextView()
                } else if let chapter = Sutra.chapters.first(where: { $0.id == id }) {
                    ChapterDetailView(chapter: chapter)
                }
            }
        }
    }

    // MARK: - Browse

    private var browseContent: some View {
        VStack(spacing: 16) {
            headerCard
            dailyVerseCard
            progressCard
            LazyVStack(spacing: 12) {
                ForEach(Sutra.chapters) { chapter in
                    NavigationLink(value: chapter.id) {
                        ChapterRow(chapter: chapter, isRead: store.readChapters.contains(chapter.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.book.closed.fill")
                .font(.system(size: 34))
                .foregroundStyle(Theme.accent)
                .padding(.bottom, 2)
            Text("《\(Sutra.title)》")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text(Sutra.translator)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.accent.opacity(0.18), lineWidth: 1)
        )
    }

    private var dailyVerseCard: some View {
        let verse = Sutra.verse(for: Date())
        return NavigationLink(value: verse.chapterID) {
            VStack(alignment: .leading, spacing: 8) {
                Label("每日一偈", systemImage: "sun.max.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                Text(verse.text)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var progressCard: some View {
        let pct = Int((store.progress * 100).rounded())
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(Theme.accent.opacity(0.15), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: max(0.001, store.progress))
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(pct)%").font(.caption.bold().monospacedDigit()).foregroundStyle(Theme.ink)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text("阅读进度")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("已读 \(store.readChapters.count) / \(Sutra.chapters.count) 分")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if store.lastReadChapter > 0,
               Sutra.chapters.contains(where: { $0.id == store.lastReadChapter }) {
                NavigationLink(value: store.lastReadChapter) {
                    Text("继续").font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Search

    private var searchResults: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            if hits.isEmpty {
                ContentUnavailableView("未找到结果", systemImage: "magnifyingglass",
                                       description: Text("没有包含「\(query)」的经文"))
                    .padding(.top, 60)
            } else {
                Text("\(hits.count) 条结果")
                    .font(.caption).foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                ForEach(hits) { hit in
                    NavigationLink(value: hit.chapter.id) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hit.chapter.fullTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                            highlighted(hit.line)
                                .font(.subheadline)
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    /// Bold the matched substring inside a result line.
    private func highlighted(_ line: String) -> Text {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, let range = line.range(of: q) else { return Text(line) }
        let pre = String(line[line.startIndex..<range.lowerBound])
        let match = String(line[range])
        let post = String(line[range.upperBound...])
        return Text(pre) + Text(match).bold().foregroundColor(Theme.accent) + Text(post)
    }
}

/// A single tappable chapter row: ordinal badge + name + read indicator + chevron.
private struct ChapterRow: View {
    let chapter: SutraChapter
    let isRead: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("\(chapter.id)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .background(Theme.accent.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(chapter.name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(chapter.ordinal)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isRead {
                Image(systemName: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(Theme.accent)
            }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    SutraHomeView().environmentObject(AppStore.shared)
}
