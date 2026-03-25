# Cast — Brand Guidelines

## App Overview
Cast is a macOS app that finds Chromecast, Google TV, Android TV, and AirPlay devices on your network and lets you send content — videos, music, photos, screens — from your Mac to the big screen.

---

## Icon Concept

**Visual:** A TV screen with a casting signal/wave emanating from it — the universal cast symbol.
- A rounded square icon
- A flat TV screen silhouette in brand primary teal
- Three curved broadcast waves emanating from the right side of the TV (like WiFi or AirPlay signals)
- Clean, minimal, instantly recognizable
- Sizes: 16, 32, 64, 128, 256, 512, 1024

**Alternative concept:** A small solid circle (device) casting a triangle (content) toward a larger rectangle (TV screen).

---

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Primary Teal | `#14B8A6` | Active casting, connected device, CTAs |
| Deep Teal | `#0D9488` | Pressed states |
| Light Teal | `#5EEAD4` | Available device highlights |
| Background Dark | `#0F172A` | Main background (dark — casting apps are dark) |
| Surface Dark | `#1E293B` | Cards, panels |
| Surface Medium | `#334155` | Device list background |
| Text Primary | `#F1F5F9` | Headings, device names |
| Text Secondary | `#94A3B8` | Subtitles, status |
| Text Muted | `#475569` | Disabled states |
| Chromecast Blue | `#4285F4` | Chromecast device indicator |
| Apple TV Gray | `#A1A1AA` | Apple TV / AirPlay indicator |
| Casting Orange | `#F97316` | Actively casting indicator (pulsing) |
| Success Green | `#22C55E` | Casting started |
| Warning | `#F59E0B` | Network issue |
| Destructive | `#EF4444` | Stop casting |

---

## Typography

- **Display / Device Name:** SF Pro Display, Semibold — 16px
- **Device Type / Status:** SF Pro Text, Regular — 13px
- **Section Headings:** SF Pro Text, Semibold — 12px, uppercase tracking
- **Body / Instructions:** SF Pro Text, Regular — 13px
- **Caption / IP Address:** SF Mono, Regular — 11px

**Font Stack:**
```
font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Mono", sans-serif;
```

---

## Visual Motif

**Theme:** "Living Room Ready" — the app should feel like a sleek TV remote or a premium streaming interface. Dark mode only. The screen real estate should prioritize the device list and casting status.

- **Device cards:** Rounded rectangles showing device icon (Chromecast TV / Apple TV), device name, model, and status dot (green = available, orange = casting)
- **Casting indicator:** A pulsing orange ring around the actively casting device
- **Network status:** Small banner at top if no devices found ("Checking your network…")
- **Empty state:** TV with "No devices found" — check network or try again
- **Now Casting bar:** When actively casting, a bottom bar shows what's being cast with a Stop button
- **Volume slider:** Simple horizontal slider when a device is selected

**Spatial rhythm:** 8pt grid. Device grid: 2 columns. Card size: 200×120px. Window fixed 460×540.

---

## macOS-Specific Behavior

- **Window:** Fixed-size `NSWindow` at 460×540. Non-resizable.
- **Menu Bar:** Persistent menu bar icon — shows cast status, click to quick-cast
- **Network discovery:** Uses `dns-sd` / Bonjour for Chromecast, native AirPlay discovery
- **Dark Mode only:** Cast apps are dark by convention
- **Keyboard shortcuts:** `⌘⇧C` cast selected device, `⌘.` stop casting, `⌘D` discover devices

---

## Sizes & Behavior

| Element | Size |
|---------|------|
| Window | 460×540 (fixed) |
| Device card | 200×120px |
| Device grid | 2 columns |
| Icon size | 24×24 |
| Menu bar icon | 18×18 |
| Status bar | 32px |

Bottom bar (when casting): 56px height. Shows thumbnail/content info + Stop button.
