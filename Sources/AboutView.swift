import SwiftUI

/// About tab — app description, developer card + link, and version.
struct AboutView: View {
    private let developerURL = URL(string: "https://www.tertiaryinfotech.com")!

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.title)
                                .foregroundStyle(Theme.accent)
                            Text("金刚经").font(.title2.bold()).foregroundStyle(Theme.ink)
                        }
                        Text("《金刚般若波罗蜜经》原文诵读应用。完整收录鸠摩罗什译本三十二分，提供分章阅读与全文连读，字体大小可调，便于日常持诵。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    // Developer card
                    VStack(alignment: .leading, spacing: 0) {
                        Text("开发者")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.top, 14)
                            .padding(.bottom, 6)
                        Label("Tertiary Infotech Academy Pte Ltd", systemImage: "building.2.fill")
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        Divider().padding(.leading, 18)
                        Link(destination: developerURL) {
                            Label("tertiaryinfotech.com", systemImage: "globe")
                        }
                        .tint(Theme.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    // Version row
                    HStack {
                        Text("版本").foregroundStyle(Theme.ink)
                        Spacer()
                        Text(versionString).foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text("愿以此功德，普及于一切，我等与众生，皆共成佛道。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(22)
            }
            .background(Theme.bg)
            .navigationTitle("关于")
        }
    }
}

#Preview {
    AboutView()
}
