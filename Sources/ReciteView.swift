import SwiftUI

/// 持诵 tab — an interactive recitation counter (念珠计数). Tap the large button
/// once per recitation; today's count, the lifetime total and progress toward a
/// daily target are tracked and persisted. Haptic feedback on every tap.
struct ReciteView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showResetConfirm = false

    private var targetProgress: Double {
        guard store.dailyTarget > 0 else { return 0 }
        return min(1, Double(store.reciteToday) / Double(store.dailyTarget))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    statsRow
                    counterButton
                    targetSection
                    Text("「受持读诵，为人演说，其福胜彼。」")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(22)
            }
            .background(Theme.bg)
            .navigationTitle("持诵")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("清零今日", role: .destructive) { store.resetToday() }
                        Button("清零总计", role: .destructive) { showResetConfirm = true }
                    } label: { Image(systemName: "ellipsis.circle") }
                    .tint(Theme.accent)
                }
            }
            .confirmationDialog("确定清零累计持诵次数？", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("清零总计", role: .destructive) { store.resetTotal() }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 14) {
            statCard(title: "今日", value: store.reciteToday)
            statCard(title: "累计", value: store.reciteTotal)
        }
    }

    private func statCard(title: String, value: Int) -> some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(Theme.ink)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var counterButton: some View {
        Button {
            store.recite()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            ZStack {
                Circle()
                    .stroke(Theme.accent.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: max(0.001, targetProgress))
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.25), value: targetProgress)
                VStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.accent)
                    Text("点击计数").font(.headline).foregroundStyle(Theme.ink)
                }
            }
            .frame(width: 230, height: 230)
        }
        .buttonStyle(.plain)
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("每日目标").font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                Spacer()
                Text("\(store.reciteToday) / \(store.dailyTarget)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(store.reciteToday >= store.dailyTarget ? Theme.accent : .secondary)
            }
            Picker("每日目标", selection: $store.dailyTarget) {
                Text("21").tag(21)
                Text("49").tag(49)
                Text("108").tag(108)
                Text("1080").tag(1080)
            }
            .pickerStyle(.segmented)
            if store.reciteToday >= store.dailyTarget {
                Label("已完成今日目标，随喜功德！", systemImage: "checkmark.seal.fill")
                    .font(.caption).foregroundStyle(Theme.accent)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ReciteView().environmentObject(AppStore.shared)
}
