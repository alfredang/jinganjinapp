import SwiftUI
import Foundation

/// Central app state — bookmarks, reading progress, recitation counter and
/// daily-reminder preferences — persisted across launches via `UserDefaults`.
/// This is the backbone that turns the reader into a stateful native app.
@MainActor
final class AppStore: ObservableObject {
    static let shared = AppStore()

    private let defaults = UserDefaults.standard

    // MARK: Bookmarks (收藏)
    @Published var bookmarks: [Int] = [] {
        didSet { defaults.set(bookmarks, forKey: Keys.bookmarks) }
    }

    // MARK: Reading progress
    @Published var readChapters: Set<Int> = [] {
        didSet { defaults.set(Array(readChapters), forKey: Keys.read) }
    }
    /// id of the chapter most recently opened (0 = none yet).
    @Published var lastReadChapter: Int = 0 {
        didSet { defaults.set(lastReadChapter, forKey: Keys.lastRead) }
    }

    // MARK: Recitation counter (持诵计数)
    @Published private(set) var reciteTotal: Int = 0
    @Published private(set) var reciteToday: Int = 0
    private var reciteDay: String = ""
    @Published var dailyTarget: Int = 108 {
        didSet { defaults.set(dailyTarget, forKey: Keys.target) }
    }

    // MARK: Daily reminder
    @Published var dailyReminderEnabled: Bool = false {
        didSet { defaults.set(dailyReminderEnabled, forKey: Keys.reminderOn) }
    }
    @Published var reminderHour: Int = 8 {
        didSet { defaults.set(reminderHour, forKey: Keys.reminderHour) }
    }
    @Published var reminderMinute: Int = 0 {
        didSet { defaults.set(reminderMinute, forKey: Keys.reminderMinute) }
    }

    private init() {
        bookmarks = (defaults.array(forKey: Keys.bookmarks) as? [Int]) ?? []
        readChapters = Set((defaults.array(forKey: Keys.read) as? [Int]) ?? [])
        lastReadChapter = defaults.integer(forKey: Keys.lastRead)
        dailyTarget = defaults.object(forKey: Keys.target) as? Int ?? 108
        dailyReminderEnabled = defaults.bool(forKey: Keys.reminderOn)
        reminderHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? 8
        reminderMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0

        reciteTotal = defaults.integer(forKey: Keys.reciteTotal)
        reciteDay = defaults.string(forKey: Keys.reciteDay) ?? Self.todayKey()
        reciteToday = (reciteDay == Self.todayKey()) ? defaults.integer(forKey: Keys.reciteToday) : 0
    }

    // MARK: - Bookmarks

    func isBookmarked(_ id: Int) -> Bool { bookmarks.contains(id) }

    func toggleBookmark(_ id: Int) {
        if let idx = bookmarks.firstIndex(of: id) { bookmarks.remove(at: idx) }
        else { bookmarks.append(id) }
    }

    // MARK: - Reading progress

    func markRead(_ id: Int) {
        readChapters.insert(id)
        lastReadChapter = id
    }

    var progress: Double {
        guard !Sutra.chapters.isEmpty else { return 0 }
        return Double(readChapters.count) / Double(Sutra.chapters.count)
    }

    func resetProgress() {
        readChapters = []
        lastReadChapter = 0
    }

    // MARK: - Recitation

    /// Register one recitation; rolls the daily count over at midnight.
    func recite() {
        rolloverIfNeeded()
        reciteToday += 1
        reciteTotal += 1
        defaults.set(reciteToday, forKey: Keys.reciteToday)
        defaults.set(reciteTotal, forKey: Keys.reciteTotal)
    }

    func resetToday() {
        reciteToday = 0
        reciteDay = Self.todayKey()
        defaults.set(0, forKey: Keys.reciteToday)
        defaults.set(reciteDay, forKey: Keys.reciteDay)
    }

    func resetTotal() {
        reciteTotal = 0
        defaults.set(0, forKey: Keys.reciteTotal)
    }

    private func rolloverIfNeeded() {
        let today = Self.todayKey()
        if reciteDay != today {
            reciteDay = today
            reciteToday = 0
            defaults.set(today, forKey: Keys.reciteDay)
            defaults.set(0, forKey: Keys.reciteToday)
        }
    }

    private static func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    private enum Keys {
        static let bookmarks = "store.bookmarks"
        static let read = "store.readChapters"
        static let lastRead = "store.lastReadChapter"
        static let reciteTotal = "store.reciteTotal"
        static let reciteToday = "store.reciteToday"
        static let reciteDay = "store.reciteDay"
        static let target = "store.dailyTarget"
        static let reminderOn = "store.dailyReminderEnabled"
        static let reminderHour = "store.reminderHour"
        static let reminderMinute = "store.reminderMinute"
    }
}
