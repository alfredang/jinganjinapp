import SwiftUI
import UIKit

/// Feedback tab — Title + Message fields, sent to the team via WhatsApp.
struct FeedbackView: View {
    private let whatsAppNumber = "6588666375"   // +65 8866 6375, country code, no "+"/spaces
    @State private var title = ""
    @State private var message = ""

    private var canSend: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                    Text("欢迎提出您的建议或反馈，我们将通过 WhatsApp 收到您的留言。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextField("请输入标题", text: $title)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        ZStack(alignment: .topLeading) {
                            if message.isEmpty {
                                Text("请输入您的反馈…")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 22)
                            }
                            TextEditor(text: $message)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 170)
                                .padding(8)
                        }
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button(action: send) {
                        Label("通过 WhatsApp 发送", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .disabled(!canSend)
                }
            .padding(22)
        }
        .background(Theme.bg)
        .navigationTitle("反馈")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func send() {
        var text = ""
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let m = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { text += "*\(t)*\n" }
        text += m
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "wa.me"
        comps.path = "/\(whatsAppNumber)"
        comps.queryItems = [URLQueryItem(name: "text", value: text)]
        if let url = comps.url { UIApplication.shared.open(url) }
    }
}

#Preview {
    FeedbackView()
}
