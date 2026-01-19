# MagicPlayMan

[![中文](https://img.shields.io/badge/中文-README-blue)](README_zh.md)

A Swift package for media playback functionality.

## Features

- Audio playback
- Playlist management
- Media asset caching
- Playback controls

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+

## Installation

Add this package to your Swift Package Manager dependencies:

```swift
.package(url: "https://github.com/nookery/MagicPlayMan.git", branch: "main")
```

Then add it to your target dependencies:

```swift
.product(name: "MagicPlayMan", package: "MagicPlayMan")
```

## Used by

Projects using MagicPlayMan:

- [Cisum_SwiftUI](https://github.com/CofficLab/Cisum_SwiftUI.git) - A media player for Apple platforms

## Usage

```swift
import MagicPlayMan

// Use MagicPlayMan for media playback
let player = MagicPlayMan()
```
