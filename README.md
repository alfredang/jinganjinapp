# 金刚经 · Diamond Sutra

A native iOS/iPadOS reader for the **《金刚般若波罗蜜经》** (Diamond Sutra, Kumārajīva translation),
built with SwiftUI. It presents the complete scripture across all **32 chapters (分)** with
chapter-by-chapter and full-text reading, Mandarin text-to-speech with live sentence
highlighting, and an adjustable, comfortable reading experience — fully offline.

![金刚经 — chapter list](screenshot.png)

## Features

- 📖 **Complete scripture** — all 32 分, from「法会因由分第一」to「应化非真分第三十二」.
- 📜 **Two reading modes** — per-chapter reader, or a continuous full-text scroll of the whole sutra.
- 🔊 **Read-aloud (TTS)** — Mandarin recitation via Apple's on-device `AVSpeechSynthesizer`,
  with the currently-spoken sentence highlighted live and adjustable speed (慢 / 正常 / 快).
- 🔠 **Adjustable text size** — scale the body type up or down; the preference persists.
- 🌙 **Light & dark mode** — a warm "sutra paper" theme via Asset Catalog color tokens.
- 📡 **Fully offline** — all text is bundled in the app; no network, no account, no data collected.
- 📱 **Universal** — adapts to both iPhone and iPad.

## Screens

| Chapter list | Reader + TTS | About |
|---|---|---|
| `经文` tab — title header + 32 chapters | per-chapter reading with 诵读 / 语速 controls | app info, developer, version |

## Tech stack

- **Swift 5** · **SwiftUI** (declarative UI, `TabView` + `NavigationStack`)
- **AVFoundation** — `AVSpeechSynthesizer` for Mandarin text-to-speech
- **XcodeGen** — project generated from [`project.yml`](project.yml)
- Deployment target **iOS 17+**, universal (iPhone + iPad)

## Project structure

```
project.yml                 # XcodeGen project definition
Sources/
  JingangJingApp.swift      # @main app entry
  MainTabView.swift         # root TabView: 经文 / 反馈 / 关于
  SutraData.swift           # full text of all 32 分 as structured data
  SutraHomeView.swift       # chapter list + header
  ChapterDetailView.swift   # per-chapter reader (TTS + highlight + font size)
  FullTextView.swift        # continuous full-sutra reading
  SpeechManager.swift       # AVSpeechSynthesizer wrapper
  FeedbackView.swift        # WhatsApp feedback form
  AboutView.swift           # app / developer / version
  Theme.swift               # central color tokens
Resources/
  Info.plist
  Assets.xcassets           # AppIcon + theme color sets
```

## Building

Requires Xcode 16+ and [XcodeGen](https://github.com/yonyz/XcodeGen) (`brew install xcodegen`).

```bash
xcodegen generate
open JingangJing.xcodeproj
# or build from the command line:
xcodebuild -project JingangJing.xcodeproj -scheme JingangJing \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

The Xcode project is generated from `project.yml` and is not checked in — run
`xcodegen generate` after cloning.

## Acknowledgements

- Scripture: 《金刚般若波罗蜜经》, 姚秦三藏法师 鸠摩罗什 译 (public domain).
- Developed by **Tertiary Infotech Academy Pte Ltd** — [tertiaryinfotech.com](https://www.tertiaryinfotech.com)

---

> 一切有为法，如梦幻泡影，如露亦如电，应作如是观。
