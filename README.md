# JourneyTH

JourneyTH is a SwiftUI iOS 17+ application that delivers a local-first travel companion for Thailand. The MVP focuses on discovering attractions, planning an itinerary, estimating city transport fares, and previewing rail connections – all without relying on network APIs.

## Features
- **Discover** – Browse 12+ curated points of interest with Thai/English metadata, quick filters by area, and one-tap itinerary additions.
- **Itinerary** – Persist favourite POIs locally with Core Data, reorder items, view total time, and share a text summary.
- **Transport – Fare Estimator** – Combine POI selections or manual coordinates, calculate distance via the Haversine formula, and estimate taxi, tuk tuk, and motorbike fares from bundled configuration.
- **Rail** – Visualise BTS/MRT/ARL/SRT stations on MapKit, select origin/destination stations, and preview estimated fares based on stop count or distance. Deep link to Apple Maps for turn-by-turn transit directions.
- **About** – Present the JourneyTH branding, methodology for calculations, bundled data sources, and disclaimers.
- **Settings** – Toggle between Thai and English at runtime and clear local itinerary data.

## Architecture & Tech
- Swift 5.9, SwiftUI, NavigationStack, MapKit, and ShareLink APIs targeting iOS 17.0.
- MVVM with dedicated view models for each feature and a lightweight service container.
- Core Data for itinerary persistence (entities provided in `JourneyTH.xcdatamodeld`).
- Local JSON bundles (`pois.json`, `fares_config.json`, `stations.json`) decoded via a `LocalDataLoader` helper.
- Offline-first design: all content and calculations run locally; no network calls are required.
- Dynamic Type friendly layouts, VoiceOver labels, and localized copy in Thai and English using `Localizable.strings`.

## Data Bundles
- `pois.json` – 12 highlighted attractions with Thai/English names, tags, coordinates, and visit duration.
- `fares_config.json` – Taxi/tuk-tuk/motorbike fare formulas plus urban/intercity rail pricing rules.
- `stations.json` – BTS, MRT, ARL, and SRT stations with line geometry for MapKit overlays.

## Building & Running
1. Open `JourneyTH.xcodeproj` in **Xcode 15** or newer.
2. Allow Xcode to resolve Swift Package Manager dependencies (the project pulls in Apple's [swift-collections](https://github.com/apple/swift-collections) package for the `OrderedCollections` module bundled with SwiftUI on iOS 17).
3. Select the **JourneyTH** scheme with an iPhone 15 Pro (iOS 17+) simulator or device.
4. Build & Run. All content is available offline via bundled resources

## Tests
Execute the unit test suite from Xcode or via command line on macOS:
```sh
xcodebuild test -scheme JourneyTH \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Disclaimers
All fares and station data are illustrative approximations for prototyping only. JourneyTH does not provide official pricing, schedules, or booking integrations.
