# moodly

**Moodly**

Moodly is a period and mood tracking app built with Flutter. It helps users log their cycle, track daily moods and symptoms, and see personalized insights about their patterns; all wrapped in a calm, minimal design.

**Features**

Login - Cycle and mood data is scoped per signed-in Google account and persists across logout/login for the same account.

Onboarding - first-time users enter their average cycle length and last period start date before anything else loads.

Calendar - month view showing:

- Logged/period days as filled dark-pink circles
- Today as a light-pink circle
- Predicted upcoming period days as dashed outline circles
- A "Current Cycle" summary card with day count, days until next period, and a phase progress bar
- A floating "+" button that opens a date picker to log a period start date for any month: past, current, or future. Logging a period always replaces the previously highlighted window, so only one period range is shown as "current" at a time; earlier logs remain in the app's stored history.


Daily Log - mood check-in (Happy, Tired, Anxious, Calm, Irritated, Angry), symptom tagging (headache, cramps, fatigue, nausea, bloating, insomnia, back ache, brain fog), and free-text daily notes.

Insights - cycle length/regularity summary, current phase, and mood trend breakdown over recent cycles.

Settings - profile summary, premium upsell banner, account/support links, and logout.

Logout - fully resets local state and returns the user to onboarding, rather than skipping back to the calendar.
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
