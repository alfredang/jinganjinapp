import Foundation
import UserNotifications

/// Schedules an optional daily reminder that surfaces 每日一偈 (verse of the day)
/// as a local notification — no server, no account, fully on-device.
enum NotificationManager {
    private static let identifier = "daily-sutra-reminder"

    /// Ask for permission; returns whether it was granted.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// (Re)schedule the repeating daily reminder at the given time.
    static func scheduleDaily(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let verse = Sutra.verse(for: Date())
        let content = UNMutableNotificationContent()
        content.title = "每日一偈 · 金刚经"
        content.body = verse.text
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
