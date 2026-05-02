# Axioo — Startup Pitch Discovery

A scroll-based video pitch discovery platform built with SwiftUI. Discover startups through TikTok-style vertical video feeds where founders share their vision in short, engaging pitch videos.

---

## Overview

Axioo reimagines startup discovery by bringing the engaging, scroll-based content format to the venture ecosystem. Instead of static pitch decks and lengthy descriptions, founders share video pitches that investors and the public can discover through an intuitive, swipeable feed.

This is a **product + design + engineering evaluation prototype** focused on delivering a fast, fluid, content-first discovery experience.

---

## Core Experience

### Video Pitch Feed
- **Vertical scroll** through full-screen startup pitch videos (TikTok-style)
- **Autoplay videos** with seamless transitions between pitches
- **Overlay UI** displaying:
  - Startup name
  - One-line pitch
  - Founder name
  - Category/industry
  - Engagement metrics (likes, saves, views)

### Interactions
- **Scroll** to browse through pitch videos
- **Swipe right** to like a pitch
- **Swipe left** to pass
- **Tap** to save/bookmark for later

---

## Features

### 📱 Three Core Pages

#### 1. Feed
- Continuous vertical scroll of video pitches
- Full-screen, immersive video playback
- Gesture-based interactions (swipe to like/pass)
- Real-time engagement metrics overlay

#### 2. Bookmarks
- Clean, simple layout of all saved pitches
- Quick access to your saved startup discoveries
- Video thumbnails with key pitch information

#### 3. Profile
- User type indicator (Founder or Investor/Public)
- Activity overview:
  - Liked pitches
  - Saved pitches
- Personal discovery history

---

## Design Language

Axioo follows a **clean, modern, premium, and minimal** design philosophy:

- **Strong typography** for clear information hierarchy
- **Content-first** approach with minimal UI chrome
- **Fluid animations** and smooth transitions
- **Gesture-driven** interactions for natural mobile experience
- **High-quality video** presentation with optimized playback

---

## Tech Stack

| Layer        | Technology             |
| ------------ | ---------------------- |
| Language     | Swift 5.10             |
| UI Framework | SwiftUI                |
| Video        | AVFoundation           |
| Architecture | MVVM                   |
| Minimum iOS  | iOS 16.0               |

---

## Project Structure

```
Axioo/
├── Models/
│   ├── AppUser.swift          # User model (Founder/Investor)
│   └── Pitch.swift            # Pitch video data model
├── ViewModels/
│   └── AppViewModel.swift     # Core app state management
├── Views/
│   ├── Feed/                  # Video feed and pitch cards
│   │   ├── FeedView.swift
│   │   ├── VideoFeedView.swift
│   │   ├── PitchCardView.swift
│   │   ├── VideoPlayerLayer.swift
│   │   └── SwipeState.swift
│   ├── Bookmarks/             # Saved pitches
│   │   └── BookmarksView.swift
│   ├── Profile/               # User profile
│   │   └── ProfileView.swift
│   └── Main/
│       └── ContentView.swift  # Tab navigation
├── Services/
│   ├── PexelsService.swift    # Video content service
│   └── PlayerCache.swift      # Video player optimization
├── DesignSystem/
│   └── DesignSystem.swift     # Design tokens and styles
└── Modifier/
    └── StrokeTextModifier.swift
```

---

## Setup Instructions

### Requirements
- macOS 13 (Ventura) or later
- Xcode 15 or later
- iPhone or Simulator running iOS 16.0+

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/axioo.git
cd axioo
```

2. **Open in Xcode**
```bash
open Axioo.xcodeproj
```

3. **Select a target**
- Choose your physical device or a simulator from the scheme picker
- Minimum deployment target is iOS 16.0

4. **Set the development team** _(required for physical device only)_
- Go to `Axioo` target → Signing & Capabilities
- Select your Apple ID team under "Team"

5. **Build & Run**
- Press `⌘ R` or click the play button
- App launches with the video pitch feed

---

## Key Implementation Details

### Video Playback
- Optimized video player with caching for smooth scrolling
- Autoplay with intelligent preloading
- Seamless transitions between videos

### Gesture Recognition
- Custom swipe gesture handlers for like/pass actions
- Vertical scroll with momentum
- Tap-to-save interaction

### Performance
- Video player caching to reduce memory footprint
- Lazy loading of video content
- Optimized for 60fps scrolling experience

---

## Evaluation Criteria

This prototype is evaluated on:

1. **Product Thinking** — Does the experience solve the discovery problem elegantly?
2. **UI/UX Quality** — Is the interface intuitive, fluid, and delightful?
3. **Visual Design** — Does it feel premium, modern, and polished?
4. **Technical Execution** — Is the implementation smooth and performant?

---

## Future Enhancements

- [ ] Founder pitch upload flow
- [ ] Advanced filtering by category/stage/location
- [ ] Direct messaging between founders and investors
- [ ] Pitch analytics dashboard for founders
- [ ] Social sharing capabilities
- [ ] Search functionality
- [ ] Personalized feed algorithm

---

## License

This project is a prototype evaluation and is not currently licensed for public use.

---

## Contact

For questions or feedback about this prototype, please reach out through the project repository.
