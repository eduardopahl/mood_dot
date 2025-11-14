## MoodDot

MoodDot is a lightweight mood-tracking Flutter app that helps users log moods, view simple statistics, and receive gentle reminders to keep a habit of daily logging.

This repository follows Clean Architecture and SOLID design principles to keep the codebase maintainable, testable, and easy to evolve.

What this README contains:
- Quick overview of the project
- How the repository maps Clean Architecture layers to folders
- Important implementation notes (notifications, ads)
- How to run and debug the app

For a more detailed architecture explanation and the full folder tree, see `ARCHITECTURE.md`.

## Overview

- Target platform: Android (notifications and AdMob behavior are primarily targeted for Android). iOS is supported for core features, but some platform-specific behavior (e.g., exact alarms) is Android-only.
- State management: `flutter_riverpod`.
- Local persistence: `hive` + `hive_flutter`.

Main features:
- Add, edit and view mood entries.
- Simple statistics and charts (using `fl_chart`).
- Daily reminder notifications with a tolerant scheduling approach and fallbacks for devices that restrict exact alarms.
- AdMob integration (banner and interstitial) and an in-app purchase (Premium) to remove ads.

## Important files and folders

- `lib/main.dart` — app bootstrap and global initialization.
- `lib/app.dart` — the `MoodDotApp` widget, localization and theme setup.
- `lib/core/services/notification_service.dart` — notification scheduling and learning logic.
- `lib/core/services/admob_service.dart` — AdMob wrapper: load/show ads and handle callbacks.
- `lib/core/services/ad_event_service.dart` — rules that decide when to show interstitials.
- `lib/presentation/pages/` — UI screens (Home, AddMood, Settings, Statistics).
- `lib/presentation/providers/` — Riverpod providers and controllers.
- `lib/domain/` — business entities, repository interfaces, and use cases.
- `lib/data/` — data layer: models, local data sources and repository implementations.

## Dependencies (high level)

- `flutter_riverpod` — state management
- `hive`, `hive_flutter` — local storage
- `flutter_local_notifications`, `timezone` — local notifications and scheduling
- `google_mobile_ads` — AdMob integration
- `permission_handler` — runtime permissions
- `fl_chart` — charts and statistics
- `in_app_purchase` — premium / in-app purchases

Refer to `pubspec.yaml` for full dependency versions.

## Local setup

1. Install dependencies:

```bash
flutter pub get
```

2. Run on an Android device or emulator:

```bash
flutter run -d <device-id>
```

3. App configuration:
- Ad unit IDs and keys are configured in `lib/config/admob_config.dart`. During development, the app uses test AdMob IDs when running in `debug`.

## Notifications (behavior and notes)

- The core notification logic lives in `lib/core/services/notification_service.dart`.
- Behavior summary:
	- When reminders are enabled, the app checks whether the user already logged a mood today. If not, it computes an optimal time and schedules reminders for the next 7 days.
	- The scheduling window is between `08:00` and `21:00` local time.
	- The service attempts to schedule exact alarms using `zonedSchedule`. If the platform throws a `PlatformException` with `exact_alarms_not_permitted`, the service falls back to scheduling a non-exact repeating alarm with `periodicallyShow`.
	- `NotificationService.initialize()` must be called during app startup; the reminders provider (`ReminderNotifier`) initializes it when loaded.

Diagnostics tips:
- Look for log entries such as `📆 Notification scheduled`, `ERROR: ❌ Failed to schedule exact notification` and `🔁 Fallback scheduled` in app logs.
- There is a small debug helper in Settings that can schedule a quick test notification (if the debug tile was enabled).

## AdMob and ads

- The AdMob logic is implemented in `lib/core/services/admob_service.dart`.
- Interstitials:
	- `loadInterstitialAd()` uses a `Completer` and awaits the `InterstitialAd.load` callback (with a timeout) to avoid returning before the ad finishes loading.
	- Display rules (in `AdEventService`): interstitials are only shown on Android, only to non-premium users, and respect a cooldown (default 3 minutes). Triggers include: every 5 mood entries, every 3 statistics views, every 2 settings opens, streak milestones, and occasional chart interactions.

Debugging ads:
- Check logs for `✅ Interstitial loaded`, `⏳ Interstitial load timeout`, or `❌ Failed to load interstitial`.
- Confirm `AdMobService.initialize()` is invoked at startup (it is called from `main.dart` in this repo).

## Premium (remove ads)

- The Premium purchase flow is in `lib/core/services/premium_service.dart` and uses `in_app_purchase`.
- The app simulates purchases in debug mode (`kDebugMode`) for easier testing.

## Testing and debugging

Run unit tests:

```bash
flutter test
```

Run and debug on Android:

```bash
flutter run -d <device-id>
# or inspect logs via adb
adb logcat -s flutter
```

Search logs for `AppLogger.d` or `AppLogger.e` and keywords like `Notification`, `Interstitial`, `AdMob`.

## Notes and best practices

- Exact alarm scheduling may require special permissions on Android and some manufacturers restrict background tasks; the app uses a safe fallback to non-exact repeating reminders when exact alarms are not permitted.
- Keep side effects at the edges (Data and Core layers) and use dependency injection (providers) to pass interfaces into the Presentation layer for better testability.

## Next steps & suggestions

- Consider adding `flutter_native_timezone` for more robust timezone detection (this requires native plugin setup and may need Gradle adjustments on Android).
- Add a debug UI to show `pendingNotificationRequests()` and ad counters for QA.
- If you want diagrams or QA checklists, I can generate PlantUML diagrams or a step-by-step QA checklist for Android.

---

If you want me to convert any other repository docs to English, or generate diagrams/checklists, tell me which one and I will add it.
