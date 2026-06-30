import SwiftUI

/// 设置 tab — reading text size, recitation speed, the daily verse reminder
/// (local notifications), and reading-progress management.
struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage(ReaderFont.key) private var fontScale: Double = 1.0
    @ObservedObject private var speech = SpeechManager.shared

    @State private var reminderTime = Date()
    @State private var notifDenied = false
    @State private var showResetProgress = false

    var body: some View {
        NavigationStack {
            Form {
                Section("阅读") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("字体大小")
                            Spacer()
                            Text("\(Int(fontScale * 100))%")
                                .foregroundStyle(.secondary).monospacedDigit()
                        }
                        Slider(value: $fontScale, in: ReaderFont.min...ReaderFont.max,
                               step: ReaderFont.step)
                            .tint(Theme.accent)
                    }
                    Picker("诵读语速", selection: $speech.rate) {
                        Text("慢").tag(0.34)
                        Text("正常").tag(0.42)
                        Text("快").tag(0.52)
                    }
                }

                Section {
                    Toggle("每日一偈提醒", isOn: $store.dailyReminderEnabled)
                        .tint(Theme.accent)
                    if store.dailyReminderEnabled {
                        DatePicker("提醒时间", selection: $reminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("提醒")
                } footer: {
                    if notifDenied {
                        Text("通知权限被关闭，请在「设置 › 通知 › 金刚经」中开启。")
                            .foregroundStyle(.red)
                    } else {
                        Text("每天定时以本地通知推送一句金刚经名句，全程离线，不收集任何数据。")
                    }
                }

                Section("进度") {
                    HStack {
                        Text("已读")
                        Spacer()
                        Text("\(store.readChapters.count) / \(Sutra.chapters.count) 分")
                            .foregroundStyle(.secondary)
                    }
                    Button("清空阅读进度", role: .destructive) { showResetProgress = true }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("设置")
            .tint(Theme.accent)
            .onAppear { reminderTime = timeFromStore() }
            .onChange(of: store.dailyReminderEnabled) { _, on in
                Task { await handleReminderToggle(on) }
            }
            .onChange(of: reminderTime) { _, _ in saveReminderTime() }
            .confirmationDialog("确定清空全部阅读进度？", isPresented: $showResetProgress,
                                titleVisibility: .visible) {
                Button("清空", role: .destructive) { store.resetProgress() }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private func timeFromStore() -> Date {
        Calendar.current.date(from: DateComponents(hour: store.reminderHour,
                                                   minute: store.reminderMinute)) ?? Date()
    }

    private func saveReminderTime() {
        let c = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        store.reminderHour = c.hour ?? 8
        store.reminderMinute = c.minute ?? 0
        if store.dailyReminderEnabled {
            NotificationManager.scheduleDaily(hour: store.reminderHour, minute: store.reminderMinute)
        }
    }

    private func handleReminderToggle(_ on: Bool) async {
        guard on else {
            NotificationManager.cancel()
            notifDenied = false
            return
        }
        let granted = await NotificationManager.requestAuthorization()
        if granted {
            notifDenied = false
            NotificationManager.scheduleDaily(hour: store.reminderHour, minute: store.reminderMinute)
        } else {
            notifDenied = true
            store.dailyReminderEnabled = false
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppStore.shared)
}
