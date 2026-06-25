import AVFoundation
import SwiftUI

/// Wraps `AVSpeechSynthesizer` to read the sutra aloud in Mandarin, publishing
/// playback state and the currently-spoken character range for live highlighting.
final class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()

    /// Identifier of the passage currently loaded (e.g. "ch-1", "full") so a view
    /// only highlights / toggles when it owns the active utterance.
    @Published private(set) var activeID: String?
    @Published private(set) var isSpeaking = false
    @Published private(set) var isPaused = false
    @Published private(set) var spokenRange: NSRange?

    /// Speech rate, persisted. Default a touch slower than system for chanting.
    @AppStorage("speechRate") var rate: Double = 0.42

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func isActive(_ id: String) -> Bool { activeID == id && isSpeaking }

    /// Start reading `text`, tagging the utterance with `id`.
    func speak(_ text: String, id: String) {
        stop()
        configureSession()
        activeID = id
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = SpeechManager.chineseVoice
        utterance.rate = Float(rate)
        utterance.postUtteranceDelay = 0.0
        synthesizer.speak(utterance)
    }

    /// Toggle play / pause / resume for a given passage.
    func toggle(_ text: String, id: String) {
        if activeID == id, isSpeaking {
            if isPaused { synthesizer.continueSpeaking() }
            else { synthesizer.pauseSpeaking(at: .word) }
        } else {
            speak(text, id: id)
        }
    }

    func stop() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
            self.spokenRange = nil
            self.activeID = nil
        }
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [])
        try? session.setActive(true)
    }

    /// Prefer a high-quality Mandarin voice when present, else any zh-CN voice.
    private static let chineseVoice: AVSpeechSynthesisVoice? = {
        let zh = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("zh") }
        if let enhanced = zh.first(where: { $0.quality != .default && $0.language == "zh-CN" }) {
            return enhanced
        }
        return AVSpeechSynthesisVoice(language: "zh-CN") ?? zh.first
    }()
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true; self.isPaused = false }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.spokenRange = characterRange }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isPaused = true }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isPaused = false }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false; self.isPaused = false
            self.spokenRange = nil; self.activeID = nil
        }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false; self.isPaused = false
            self.spokenRange = nil; self.activeID = nil
        }
    }
}
