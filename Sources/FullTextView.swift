import SwiftUI

/// Continuous full-text reading of all 32 分 in one scroll, with the same
/// adjustable text size as the per-chapter reader.
struct FullTextView: View {
    @AppStorage(ReaderFont.key) private var fontScale: Double = 1.0
    @ObservedObject private var speech = SpeechManager.shared

    private let speechID = "full"
    private var bodyFont: Font { .system(size: 19 * fontScale, weight: .regular) }

    /// The whole sutra as one speakable string (title + every section).
    private var fullSpeech: String {
        var parts = ["金刚般若波罗蜜经。"]
        for c in Sutra.chapters { parts.append(c.fullTitle + "。" + c.body) }
        return parts.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(spacing: 6) {
                    Text("《\(Sutra.title)》")
                        .font(.system(size: 24 * min(fontScale, 1.3), weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text(Sutra.translator)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                ForEach(Sutra.chapters) { chapter in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(chapter.fullTitle)
                            .font(.system(size: 20 * min(fontScale, 1.3), weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text(chapter.body)
                            .font(bodyFont)
                            .foregroundStyle(Theme.ink)
                            .lineSpacing(11 * fontScale)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(22)
            .textSelection(.enabled)
        }
        .background(Theme.bg)
        .navigationTitle("全文")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                let playing = speech.activeID == speechID && speech.isSpeaking && !speech.isPaused
                Button {
                    if speech.activeID == speechID && speech.isSpeaking {
                        speech.stop()
                    } else {
                        speech.speak(fullSpeech, id: speechID)
                    }
                } label: {
                    Image(systemName: playing ? "stop.circle.fill" : "play.circle.fill")
                }
                .tint(Theme.accent)
                .accessibilityLabel(playing ? "停止诵读" : "诵读全文")
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
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
}

#Preview {
    NavigationStack { FullTextView() }
}
