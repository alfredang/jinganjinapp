import SwiftUI

/// Home tab — title header + the list of 32 分, each pushing a reading view.
struct SutraHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    LazyVStack(spacing: 12) {
                        ForEach(Sutra.chapters) { chapter in
                            NavigationLink(value: chapter.id) {
                                ChapterRow(chapter: chapter)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .background(Theme.bg)
            .navigationTitle("金刚经")
            .navigationBarTitleDisplayMode(.inline)
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
}

/// A single tappable chapter row: ordinal badge + name + chevron.
private struct ChapterRow: View {
    let chapter: SutraChapter

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
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    SutraHomeView()
}
