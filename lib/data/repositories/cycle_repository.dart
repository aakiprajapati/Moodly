import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_data.dart';
import '../models/mood_entry.dart';
import '../models/user_profile.dart';

/// Abstract data source contract. Swapping [LocalCycleRepository] for a
/// Firestore/REST-backed implementation later only requires implementing
/// this interface — presentation code never changes.
abstract class CycleRepository {
  /// Returns null until the user has completed onboarding — this is
  /// what lets [CycleProvider.hasOnboarded] tell a real "new user" apart
  /// from a returning one.
  Future<CycleData?> fetchCycleData();
  Future<UserProfile> fetchUserProfile();
  Future<List<MoodEntry>> fetchMoodEntries();
  Future<void> saveOnboarding({
    required int averageCycleLengthDays,
    required DateTime lastPeriodStartDate,
  });
  Future<void> saveMoodEntry(MoodEntry entry);

  /// Logs a period start date, replacing whatever period window is
  /// currently shown — only one highlighted period window exists at a
  /// time. The picked date becomes the new anchor used for "current day
  /// in cycle" calculations.
  Future<void> logPeriodStart(DateTime periodStartDate);

  /// Ends the current session. Does NOT delete the signed-in account's
  /// saved data — that stays on disk so it's there again on next login.
  Future<void> logout();
}

/// SharedPreferences-backed implementation for this coursework build.
/// Cycle data and mood entries are persisted as JSON, keyed per Firebase
/// user id, so each Google account keeps its own data across logout and
/// re-login. Simulates realistic network latency so loading states in
/// the UI are exercised rather than dead code paths.
class LocalCycleRepository implements CycleRepository {
  LocalCycleRepository();

  static const _simulatedLatency = Duration(milliseconds: 600);

  // Serializes writes (saveOnboarding / saveMoodEntry / logPeriodStart)
  // so overlapping calls — e.g. rapid taps on the "+" button — can't
  // race each other. Each write's read-modify-write cycle now waits for
  // the previous write to fully finish before it starts its own read,
  // preventing a second call from reading stale data and silently
  // clobbering the first call's update.
  Future<void> _writeLock = Future.value();

  Future<T> _synchronized<T>(Future<T> Function() action) {
    final previous = _writeLock;
    final completer = Completer<T>();
    _writeLock = previous.then((_) => null).catchError((_) {}).then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _cycleKey(String uid) => 'cycle_data_$uid';
  String _moodKey(String uid) => 'mood_entries_$uid';

  // ---- JSON helpers -----------------------------------------------

  Map<String, dynamic> _cycleDataToJson(CycleData data) => {
    'averageCycleLengthDays': data.averageCycleLengthDays,
    'lastPeriodStartDate': data.lastPeriodStartDate.toIso8601String(),
    'regularityPercent': data.regularityPercent,
    'loggedDates':
    data.loggedDates.map((d) => d.toIso8601String()).toList(),
  };

  CycleData _cycleDataFromJson(Map<String, dynamic> json) => CycleData(
    averageCycleLengthDays: json['averageCycleLengthDays'] as int,
    lastPeriodStartDate:
    DateTime.parse(json['lastPeriodStartDate'] as String),
    regularityPercent: json['regularityPercent'] as int,
    loggedDates: (json['loggedDates'] as List)
        .map((s) => DateTime.parse(s as String))
        .toSet(),
  );

  Map<String, dynamic> _moodEntryToJson(MoodEntry e) => {
    'date': e.date.toIso8601String(),
    'mood': e.mood?.name,
    'symptoms': e.symptoms.map((s) => s.name).toList(),
    'notes': e.notes,
  };

  MoodEntry _moodEntryFromJson(Map<String, dynamic> json) => MoodEntry(
    date: DateTime.parse(json['date'] as String),
    mood: json['mood'] != null
        ? MoodType.values.byName(json['mood'] as String)
        : null,
    symptoms: (json['symptoms'] as List)
        .map((s) => Symptom.values.byName(s as String))
        .toSet(),
    notes: json['notes'] as String? ?? '',
  );

  // ---- Reads --------------------------------------------------------

  @override
  Future<CycleData?> fetchCycleData() async {
    await Future.delayed(_simulatedLatency);
    final uid = _uid;
    if (uid == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cycleKey(uid));
    if (raw == null) return null;

    return _cycleDataFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<UserProfile> fetchUserProfile() async {
    await Future.delayed(_simulatedLatency);
    final user = FirebaseAuth.instance.currentUser;
    return UserProfile(
      name: user?.displayName ?? 'Moodly User',
      email: user?.email ?? '',
      isPremium: false,
    );
  }

  @override
  Future<List<MoodEntry>> fetchMoodEntries() async {
    await Future.delayed(_simulatedLatency);
    final uid = _uid;
    if (uid == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_moodKey(uid));
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => _moodEntryFromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Writes ---------------------------------------------------------

  @override
  Future<void> saveOnboarding({
    required int averageCycleLengthDays,
    required DateTime lastPeriodStartDate,
  }) {
    return _synchronized(() async {
      await Future.delayed(_simulatedLatency);
      if (averageCycleLengthDays <= 0) {
        throw ArgumentError('Cycle length must be greater than 0');
      }

      final uid = _uid;
      if (uid == null) throw StateError('No signed-in user.');

      final existing = await fetchCycleData();

      // The 5 days starting from lastPeriodStartDate represent the period
      // itself — shown as dark pink "logged" circles on the calendar,
      // matching the menstrual-phase window used in CycleData.phase.
      final periodDates = List.generate(
        5,
            (i) => DateTime(
          lastPeriodStartDate.year,
          lastPeriodStartDate.month,
          lastPeriodStartDate.day,
        ).add(Duration(days: i)),
      );

      final CycleData updated;
      if (existing == null) {
        // First-time onboarding: create the initial CycleData from
        // scratch using what the user entered.
        updated = CycleData(
          averageCycleLengthDays: averageCycleLengthDays,
          lastPeriodStartDate: lastPeriodStartDate,
          regularityPercent: 94,
          loggedDates: {...periodDates},
        );
      } else {
        // Re-onboarding / editing details later: keep existing
        // loggedDates (e.g. mood check-ins) and merge in the new period
        // range, updating the two changed fields.
        updated = existing.copyWith(
          averageCycleLengthDays: averageCycleLengthDays,
          lastPeriodStartDate: lastPeriodStartDate,
          loggedDates: {...existing.loggedDates, ...periodDates},
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cycleKey(uid), jsonEncode(_cycleDataToJson(updated)));
    });
  }

  @override
  Future<void> saveMoodEntry(MoodEntry entry) {
    return _synchronized(() async {
      await Future.delayed(_simulatedLatency);
      final uid = _uid;
      if (uid == null) throw StateError('No signed-in user.');

      final entries = await fetchMoodEntries();
      entries.removeWhere((e) =>
      e.date.year == entry.date.year &&
          e.date.month == entry.date.month &&
          e.date.day == entry.date.day);
      entries.add(entry);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _moodKey(uid),
        jsonEncode(entries.map(_moodEntryToJson).toList()),
      );

      final current = await fetchCycleData();
      if (current != null) {
        final updatedLoggedDates = {...current.loggedDates, entry.date};
        final updatedCycle = current.copyWith(loggedDates: updatedLoggedDates);
        await prefs.setString(
          _cycleKey(uid),
          jsonEncode(_cycleDataToJson(updatedCycle)),
        );
      }
    });
  }

  @override
  Future<void> logPeriodStart(DateTime periodStartDate) {
    return _synchronized(() async {
      await Future.delayed(_simulatedLatency);
      final uid = _uid;
      if (uid == null) throw StateError('No signed-in user.');

      final existing = await fetchCycleData();
      final startDateOnly = DateTime(
        periodStartDate.year,
        periodStartDate.month,
        periodStartDate.day,
      );

      // Same 5-day period window convention used in saveOnboarding.
      final periodDates =
      List.generate(5, (i) => startDateOnly.add(Duration(days: i)));

      final CycleData updated;
      if (existing == null) {
        // No cycle set up yet at all — create one with a sensible default
        // average length; the user can adjust it later via onboarding/settings.
        updated = CycleData(
          averageCycleLengthDays: 28,
          lastPeriodStartDate: startDateOnly,
          regularityPercent: 94,
          loggedDates: {...periodDates},
        );
      } else {
        // Every log replaces whatever period window is currently
        // shown — only one highlighted period window exists at a time,
        // no matter what date the user picks.
        final oldStartOnly = DateTime(
          existing.lastPeriodStartDate.year,
          existing.lastPeriodStartDate.month,
          existing.lastPeriodStartDate.day,
        );
        final oldWindow =
        List.generate(5, (i) => oldStartOnly.add(Duration(days: i)));

        final mergedLoggedDates = {...existing.loggedDates}
          ..removeAll(oldWindow)
          ..addAll(periodDates);

        updated = existing.copyWith(
          lastPeriodStartDate: startDateOnly,
          loggedDates: mergedLoggedDates,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cycleKey(uid), jsonEncode(_cycleDataToJson(updated)));
    });
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_simulatedLatency);
    // Intentionally does nothing to saved data. Cycle data and mood
    // entries are persisted per-account in SharedPreferences, so they
    // must survive logout — they'll be read back in on next login via
    // fetchCycleData()/fetchMoodEntries(). CycleProvider separately
    // clears its own in-memory fields so the UI resets to a clean
    // "no session" state until the next login loads this account's
    // data back in.
  }
}