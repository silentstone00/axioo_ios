# Axioo — Startup Pitch Discovery

A scroll-based video pitch discovery platform built with SwiftUI. Discover startups through TikTok-style vertical video feeds where founders share their vision in short, engaging pitch videos.

- **Demo Video**: [Watch on Google Drive](https://drive.google.com/file/d/1fbSLjim1Iy94OFHbBK7OqNQ6_1LMPfUZ/view?usp=sharing)

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

## Setup Instructions

### Requirements
- macOS 13 (Ventura) or later
- Xcode 15 or later
- iPhone or Simulator running iOS 16.0+

### Steps

1. **Clone the repository**
```bash
git clone [https://github.com/yourusername/axioo.git](https://github.com/silentstone00/axioo_ios.git)
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
