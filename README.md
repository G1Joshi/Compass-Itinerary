# Compass Itinerary 🧭

A production-grade travel itinerary and vacation planning application engineered strictly in accordance with [Google's Official Flutter App Architecture](https://docs.flutter.dev/app-architecture) and its 10 architectural subpages.

---

## 🏛️ Architectural Highlights

- **UI Layer (MVVM)**: Pure `ChangeNotifier` and `ListenableBuilder` reactive bindings with zero third-party state managers.
- **Command Pattern**: `Command0<T>` and `Command1<T, A>` encapsulate async actions, prevent button re-entrancy / double-taps, and bind loading & error states natively.
- **Sealed Result Pattern**: `Result<T>` (`Ok<T>` and `Error<T>`) eliminates unhandled runtime exceptions and integrates with Dart 3 exhaustive pattern matching.
- **Single Source of Truth (SSOT) & Optimistic Updates**: Repositories cache data, update locally before network calls, and automatically roll back on simulated errors.
- **Testing with Fakes**: Fully isolated, fast unit and widget test suite using in-memory `FakeRepositories` instead of heavy mocking frameworks.
- **Dependency Injection**: Declarative top-level `MultiProvider` wiring Services ➔ Repositories ➔ Use Cases ➔ ViewModels ➔ Widgets.

---

## 🚀 Running the App

```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run the 30-test automated suite
flutter test

# Run in Google Chrome
flutter run -d chrome
```

## 📸 Screenshots

|                                                                                                             |                                                                                                             |                                                                                                             |                                                                                                             |
| ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| ![](https://raw.githubusercontent.com/G1Joshi/Assets/refs/heads/main/ScreenShots/compass_itinerary/SS1.png) | ![](https://raw.githubusercontent.com/G1Joshi/Assets/refs/heads/main/ScreenShots/compass_itinerary/SS2.png) | ![](https://raw.githubusercontent.com/G1Joshi/Assets/refs/heads/main/ScreenShots/compass_itinerary/SS3.png) | ![](https://raw.githubusercontent.com/G1Joshi/Assets/refs/heads/main/ScreenShots/compass_itinerary/SS4.png) |
