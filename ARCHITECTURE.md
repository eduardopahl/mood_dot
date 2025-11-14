# Architecture and Folder Structure

This document explains how the project maps Clean Architecture principles to a Flutter codebase and shows the folder structure used throughout the repository. The intent is to make responsibilities clear and to align with SOLID design principles.

## High-level principles

- Clean Architecture: separate the code into layers with clear dependency rules:
  - Presentation -> depends on Domain -> depends on Data (but not the other way around)
  - The Domain layer contains business rules and is platform-agnostic.
- SOLID: aim for single responsibility, small interfaces, dependency inversion (depend on abstractions), and open/closed design.

## Folder structure (recommended)

```
lib/
  app.dart                  # App widget, provider wiring and top-level configuration
  main.dart                 # Flutter entrypoint, perform initialization here

  core/                     # Cross-cutting concerns and platform adapters
    services/                # Singleton services (notification, admob, logging, premium)
    utils/                   # Utility helpers (formatters, validators)
    exceptions/              # App-specific exception types

  presentation/             # UI layer (depends on domain interfaces)
    pages/                   # Screens (Home, AddMood, Settings, Statistics)
    widgets/                 # Reusable UI widgets
    providers/               # Riverpod providers and controllers
    dialogs/                 # Dialogs and bottom sheets
    theme/                   # Theme data, app-level styles

  domain/                   # Business logic layer (pure Dart)
    entities/                # Core entities (Mood, User, Stats)
    repositories/            # Repository interfaces (abstract contracts)
    use_cases/               # Interactors / use cases (application-specific operations)

  data/                     # Data layer (implements domain contracts)
    datasources/             # Local/remote data sources (Hive, network clients)
    models/                  # DTOs / local models and mappers
    repositories/            # Repository implementations that satisfy domain interfaces

  l10n/                     # Localization source files (.arb)
  generated/                # Generated localization code

test/                       # Unit and widget tests

android/                    # Native Android project (Gradle, manifest, keystore)
ios/                        # Native iOS project files

README.md
ARCHITECTURE.md
```

## Responsibilities per layer

- Presentation:
  - UI widgets and pages, view models / providers that orchestrate presentation logic.
  - Should depend only on abstractions from `domain` (use cases, repository interfaces).
  - No direct data source access (use repository interfaces instead).

- Domain:
  - Entities and use cases encapsulate business rules.
  - Repository interfaces define what data operations the domain needs.
  - No Flutter or platform-specific code here — pure Dart for testability.

- Data:
  - Implements repository interfaces from `domain`.
  - Contains details about storage (Hive), network clients, and models mapping.
  - Can depend on platform packages and plugins.

- Core:
  - Shared services used across the app (notifications, ads, logging, permissions).
  - These services may use Data layer classes (via interfaces) or provide adapters to platform features.

## Dependency rules

- The Domain layer must not depend on Presentation or Data implementations.
- Presentation depends on Domain interfaces (use cases) and uses Providers to orchestrate interactions.
- Data depends on Domain abstractions (repository interfaces) so that implementations can be swapped or mocked in tests.
- Core services should be small, single-purpose, and expose interfaces where convenient so they can be mocked in tests.

## Examples in this repo

- `lib/core/services/notification_service.dart` — platform adapter that uses `flutter_local_notifications` and schedules reminders. Presentation code interacts with this service via providers.
- `lib/domain/use_cases/` — contains use cases like `AddMood`, `GetMoodHistory`, `GetStatistics` (pure business logic).
- `lib/data/repositories/` — implements domain repository interfaces using Hive or other local storage.

## Testing strategy

- Unit tests for `domain` use cases and pure functions.
- Widget tests and provider/controller tests in `presentation` using mocked repositories and services.
- Integration tests may run against a real device or emulator for notifications and ad flows.

## Notes and suggestions

- Favor small, single-responsibility classes and abstractions (SOLID).
- Keep side effects (database, network, notifications) at the edges (Data and Core layers).
- Use dependency injection (providers) to pass implementations into the presentation layer and make testing straightforward.

---

If you want, I can also generate format-friendly PlantUML or sequence diagrams for the most important flows (notification scheduling, ad display flow, mood entry flow). Say which flow you want diagrammed next.