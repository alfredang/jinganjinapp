import SwiftUI

@main
struct JingangJingApp: App {
    @StateObject private var store = AppStore.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .task {
                    // Keep the daily verse in any scheduled reminder current.
                    if store.dailyReminderEnabled,
                       await NotificationManager.authorizationStatus() == .authorized {
                        NotificationManager.scheduleDaily(hour: store.reminderHour,
                                                          minute: store.reminderMinute)
                    }
                }
        }
    }
}
