# JourneyTH

JourneyTH is a SwiftUI iOS 17+ application that showcases a travel assistant for Thailand. The app is designed around MVVM, Core Data persistence, and local-first mocks so it can run entirely offline. All services expose protocols with mock implementations, Apple Maps routes rely on MapKit, and UI strings are localized in Thai and English.

## Features
- **Transport** – Search BTS, bus, ferry, and walking combinations using mock routes from `transport.json`, pick a departure time, and open annotated MapKit polylines for any route.
- **Discover** – Browse and filter 12+ points of interest by region and tags, switch between list and map modes, and add destinations to the itinerary.
- **Itinerary** – Persist selected POIs with Core Data, reorder via drag & drop, calculate total minutes, and export a share sheet summary.
- **eSIM & Payments** – Explore mock plans, generate QR previews, create offline orders, and mark activations that update order status badges.
- **Account** – Toggle the live language between Thai/English, clear persisted data, and view local profile info.

## Architecture & Tech Highlights
- Swift 5.9+, SwiftUI-only UI components, NavigationStack, TabView, and modern MapKit APIs.
- MVVM for each feature module with dedicated view models and services.
- Core Data entities (`Itinerary`, `ItineraryItem`, `Order`) with repositories that expose async/await helpers.
- Local JSON loaders (`transport.json`, `pois.json`, `esim_plans.json`) consumed via strongly typed models.
- Mock service layer (`TransportServiceProtocol`, `PoiServiceProtocol`, `OrderServicing`, `PaymentProviding`, `PlanLoading`).
- Localization via `Localizable.strings` (TH + EN) with runtime switching through `AppSettings` and `@AppStorage`.
- Accessibility considerations: Dynamic Type-friendly layouts, descriptive VoiceOver labels, and haptic feedback on key actions.

## Project Structure
```
JourneyTH-app/
├─ JourneyTH.xcodeproj/
├─ JourneyTH/
│  ├─ JourneyTHApp.swift
│  ├─ Features/
│  │  ├─ Transport/…
│  │  ├─ Discover/…
│  │  ├─ Itinerary/…
│  │  ├─ Esim/…
│  │  ├─ Payments/…
│  │  ├─ Account/…
│  │  └─ Shared/…
│  ├─ Services/
│  ├─ Models/
│  ├─ Resources/
│  │  ├─ Data/
│  │  ├─ Localizations/
│  │  └─ Assets.xcassets/
│  ├─ CoreData/
│  └─ Tests/
├─ generate_pbx.py
└─ README.md
```
Use `python generate_pbx.py` to regenerate `JourneyTH.xcodeproj/project.pbxproj` after adding/removing files.

## Building & Running
 codex/create-ios-app-journeyth-with-swiftui-mvvm-jvmpwp
1. Open `JourneyTH.xcodeproj` in **Xcode 15 or newer** (project format 56 / compatibility Xcode 15.0). If Xcode reports a parse error, make sure you have upgraded to Xcode 15 and re-run `python generate_pbx.py` to restore the project file from source control.

main
2. Select the **JourneyTH** scheme and an iPhone 15 Pro (iOS 17+) simulator or device.
3. Build & Run. No external APIs are required; all data loads from bundled mocks.

## Running Tests
Execute the unit test suite (11 tests) from Xcode or via the command line on macOS:
```sh
xcodebuild test -scheme JourneyTH \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Local Data
Sample data lives in `JourneyTH/Resources/Data/`:
- `transport.json` – 6+ transport routes with multi-modal steps and sample coordinates.
- `pois.json` – 12 points of interest with metadata, tags, and asset references.
- `esim_plans.json` – Mock eSIM plans used by the checkout flow.

## Localization & Accessibility
All visible strings exist in both `en.lproj` and `th.lproj`. The Account tab exposes a toggle that updates `AppSettings` and rebinds the app’s locale. Components include VoiceOver labels, proper contrast, and respect Dynamic Type.

## Known Limitations
- Mock data only; no live network or payment integrations.
- Map polylines and travel times are illustrative.
- Assets are placeholder PNGs for demonstration.

Happy travels! ✈️🌏
