# HABITLY – Daily Habit & Progress Tracker
### BIT313 Human-Computer Interaction | Assessment 3 Mobile Application

> **Tagline:** *"Build Better Habits. Become Better Every Day."*  
> **Brand Personality:** Premium, Minimal, Friendly, Motivational, Modern, Clean.  
> **Theme:** Light Theme Optimized for Accessibility, Contrast, and Clean Usability.

---

## 1. Project Overview & HCI Evaluation Summary

**Habitly** is a university-grade, offline-first personal habit tracking and progress monitoring mobile application built specifically for **BIT313 Human-Computer Interaction (HCI) Assessment 3**.

The application was designed strictly following foundational **HCI principles and Jakob Nielsen's Usability Heuristics**:
1. **Visibility of System Status:**
   - Real-time circular progress ring on the dashboard (`CustomProgressRing`).
   - Dynamic completion counter ($X$ of $Y$ completed).
   - Instant visual response (micro-animations, state changes, and snackbar confirmations).
2. **Match Between System and Real World:**
   - Natural language dates, motivational milestones, and intuitive habit categories (Health, Fitness, Learning, Productivity, Mindfulness, Personal).
3. **User Control & Freedom:**
   - One-tap toggle allows undoing today's habit check-ins.
   - Comprehensive habit editing and archive/unarchive workflows.
4. **Consistency & Standards:**
   - Unified Material 3 design system with brand Indigo (`#4F46E5`), Soft Lavender (`#818CF8`), and Mint Green (`#10B981`).
   - Standard 5-tab bottom navigation bar (`Home`, `Habits`, `Calendar`, `Analytics`, `Profile`).
5. **Error Prevention & Recovery:**
   - Form input validation (minimum character length, required fields, non-empty names).
   - Duplicate active habit detection.
   - Clear confirmation dialogs for destructive actions (habit deletion, data reset).
6. **Recognition Rather Than Recall:**
   - Category chips, visual habit icons, color tags, and interactive calendar indicator dots.
7. **Meaningful Data Visualizations:**
   - Handcrafted `CustomPainter` widgets for:
     - 7-Day Completion Bar Chart with percentage markers.
     - Category Distribution Donut Chart with live legend.
     - 30-Day Monthly Consistency Smooth Curve Trend.

---

## 2. Strict Technology Compliance

- **Framework:** Flutter (Channel stable, Dart 3.x)
- **External Dependencies:** **0 (Zero)**. No third-party packages, no Firebase, no REST APIs, no external chart libraries.
- **Data Persistence:** Offline local file persistence utilizing Dart core libraries (`dart:io` and `dart:convert`) paired with native Android `filesDir` channel integration (`com.habitly.app/storage`).
- **State Management:** Native `ChangeNotifier` and reactive widgets.

---

## 3. Directory Structure

```text
Habitly/
├── android/
│   └── app/src/main/kotlin/com/habitly/app/habitly/MainActivity.kt  (Native filesDir MethodChannel)
├── lib/
│   ├── main.dart                          (Application entry point)
│   ├── app.dart                           (Root MaterialApp & theme setup)
│   ├── core/
│   │   ├── constants/app_constants.dart   (Categories, icons, colors, filenames)
│   │   ├── theme/app_theme.dart           (Light Theme Material 3 design system)
│   │   ├── utils/date_utils.dart          (Pure Dart date parsing, normalization, formatting)
│   │   └── storage/local_storage.dart     (Dart file I/O & export logic)
│   ├── models/
│   │   ├── habit.dart                     (Habit data model)
│   │   ├── habit_completion.dart          (Daily completion record model)
│   │   └── user_profile.dart              (Profile model)
│   ├── providers/
│   │   ├── habit_provider.dart            (Habit state, streak logic, statistics)
│   │   └── profile_provider.dart          (User profile & onboarding state)
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── splash_screen.dart         (Animated launch logo & transition)
│   │   │   └── onboarding_screen.dart     (3-step introductory walkthrough)
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart      (Home screen, progress ring, today's habits)
│   │   │   └── main_navigation_screen.dart (5-destination bottom navigation bar)
│   │   ├── habits/
│   │   │   ├── habits_screen.dart         (Active/Archived tabs, search, filters)
│   │   │   ├── add_habit_screen.dart      (Create/Edit habit with validation)
│   │   │   └── habit_detail_screen.dart   (14-day history, streaks, metrics)
│   │   ├── calendar/
│   │   │   └── calendar_screen.dart       (Custom monthly grid, date-based habit log)
│   │   ├── analytics/
│   │   │   └── analytics_screen.dart      (CustomPainter charts & KPIs)
│   │   └── profile/
│   │       ├── profile_screen.dart        (Profile summary, HCI evaluation table)
│   │       └── settings_screen.dart       (JSON export, reminders, data reset)
│   └── widgets/
│       ├── custom_progress_ring.dart      (Custom-painted circular progress indicator)
│       ├── habit_card.dart                (Habit card with micro-interactions)
│       ├── chart_widgets.dart             (CustomPainter bar, donut, and line charts)
│       └── empty_state.dart               (Engaging empty states)
├── test/
│   └── widget_test.dart                   (Unit tests for models & business logic)
└── pubspec.yaml                           (Standard Flutter SDK dependencies only)
```

---

## 4. How to Run the Project

### Prerequisites
- Flutter SDK installed and available on PATH (`flutter --version`)
- Android SDK configured (for emulator or connected USB device)

### Execution Steps
1. Navigate to the project root:
   ```bash
   cd "C:\Users\Toshak Sharma\.gemini\antigravity\scratch\Habitly"
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run analyzer:
   ```bash
   flutter analyze
   ```
4. Run unit tests:
   ```bash
   flutter test
   ```
5. Run on connected Android device/emulator:
   ```bash
   flutter run
   ```

---

## 5. Built Artifacts
- **Debug APK:** `build/app/outputs/flutter-apk/app-debug.apk`
- Ready for academic presentation and real device demonstration.
