import SwiftUI

/// Reading view for a single 分 — large, comfortable typography with an
/// adjustable text size, text-to-speech with live highlighting, and
/// chapter-to-chapter navigation.
struct ChapterDetailView: View {
    let chapter: SutraChapter
    @AppStorage(ReaderFont.key) private var fontScale: Double = 1.0
    @ObservedObject private var speech = SpeechManager.shared
    @EnvironmentObject private var store: AppStore

    /// Plain-text share payload for this 分.
    private var shareText: String { "《金刚经》\(chapter.fullTitle)\n\n\(chapter.body)" }

    private var speechID: String { "ch-\(chapter.id)" }
    private var bodyFontSize: CGFloat { 19 * fontScale }

    /// Body as an AttributedString, highlighting the range currently being spoken.
    private var attributedBody: AttributedString {
        var attr = AttributedString(chapter.body)
        attr.font = .system(size: bodyFontSize)
        attr.foregroundColor = Theme.ink
        guard speech.activeID == speechID,
              let nsRange = speech.spokenRange,
              let r = Range(nsRange, in: chapter.body),
              let lower = AttributedString.Index(r.lowerBound, within: attr),
              let upper = AttributedString.Index(r.upperBound, within: attr)
        else { return attr }
        attr[lower..<upper].foregroundColor = Theme.accent
        attr[lower..<upper].font = .system(size: bodyFontSize, weight: .bold)
        return attr
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Chapter heading
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.ordinal)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text(chapter.name)
                        .font(.system(size: 26 * min(fontScale, 1.3), weight: .bold))
                        .foregroundStyle(Theme.ink)
                }

                playbackBar

                Divider().overlay(Theme.accent.opacity(0.25))

                Text(attributedBody)
                    .lineSpacing(11 * fontScale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)

                chapterNav
            }
            .padding(22)
        }
        .background(Theme.bg)
        .navigationTitle(chapter.fullTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.markRead(chapter.id) }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    store.toggleBookmark(chapter.id)
                } label: {
                    Image(systemName: store.isBookmarked(chapter.id) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(store.isBookmarked(chapter.id) ? "取消收藏" : "收藏")

                ShareLink(item: shareText) { Image(systemName: "square.and.arrow.up") }
                    .accessibilityLabel("分享")

                Button {
                    fontScale = max(ReaderFont.min, fontScale - ReaderFont.step)
                } label: { Image(systemName: "textformat.size.smaller") }
                    .disabled(fontScale <= ReaderFont.min + 0.001)
                    .accessibilityLabel("缩小字体")

                Button {
                    fontScale = min(ReaderFont.max, fontScale + ReaderFont.step)
                } label: { Image(systemName: "textformat.size.larger") }
                    .disabled(fontScale >= ReaderFont.max - 0.001)
                    .accessibilityLabel("放大字体")
            }
        }
    }

    /// Play / pause + stop + speed controls for read-aloud.
    private var playbackBar: some View {
        let active = speech.activeID == speechID && speech.isSpeaking
        let playing = active && !speech.isPaused
        return HStack(spacing: 14) {
            Button {
                speech.toggle(chapter.body, id: speechID)
            } label: {
                Label(playing ? "暂停" : "诵读",
                      systemImage: playing ? "pause.circle.fill" : "play.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)

            if active {
                Button {
                    speech.stop()
                } label: {
                    Image(systemName: "stop.circle.fill").font(.headline)
                }
                .tint(Theme.accent)
                .accessibilityLabel("停止")
            }

            Spacer()

            Menu {
                Picker("语速", selection: $speech.rate) {
                    Text("慢").tag(0.34)
                    Text("正常").tag(0.42)
                    Text("快").tag(0.52)
                }
            } label: {
                Label("语速", systemImage: "gauge.with.dots.needle.50percent")
                    .font(.subheadline)
            }
            .tint(Theme.accent)
        }
    }

    /// Previous / next chapter buttons at the foot of the reading view.
    @ViewBuilder private var chapterNav: some View {
        let prev = Sutra.chapters.first { $0.id == chapter.id - 1 }
        let next = Sutra.chapters.first { $0.id == chapter.id + 1 }
        HStack {
            if let prev {
                NavigationLink(value: prev.id) {
                    Label(prev.name, systemImage: "chevron.left")
                        .font(.subheadline)
                }
            }
            Spacer()
            if let next {
                NavigationLink(value: next.id) {
                    Label(next.name, systemImage: "chevron.right")
                        .font(.subheadline)
                        .labelStyle(TrailingIconLabelStyle())
                }
            }
        }
        .tint(Theme.accent)
        .padding(.top, 8)
    }
}

/// Puts the SF Symbol after the text (for "next" links).
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}

#Preview {
    NavigationStack {
        ChapterDetailView(chapter: Sutra.chapters[0])
    }
    .environmentObject(AppStore.shared)
}
