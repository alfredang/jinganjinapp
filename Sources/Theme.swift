import SwiftUI

/// Central color tokens — every color comes from here so light/dark mode swap automatically.
/// Each token is backed by an Asset Catalog color set with Light + Dark appearance variants.
enum Theme {
    static let accent = Color("Accent")       // warm saffron / bronze — tab tint, links, buttons
    static let card   = Color("Card")         // grouped-card surface
    static let bg      = Color("Background")  // warm paper background
    static let ink     = Color("Ink")          // sutra body text
}

/// Reader text-size preference, persisted across launches.
enum ReaderFont {
    static let key = "readerFontScale"
    static let min: Double = 0.85
    static let max: Double = 1.6
    static let step: Double = 0.1
}
