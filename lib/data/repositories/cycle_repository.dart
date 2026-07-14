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

  /// Clears all locally held user data (cycle data, mood entries) so
  /// the next splash-screen check correctly routes back to onboarding
  /// instead of treating this as a returning, already-onboarded user.
  Future<void> logout();
}

/// In-memory implementation used for this coursework build. Simulates
/// realistic network latency (and can simulate failure) so loading and
/// error states in the UI are exercised rather than dead code paths.
class LocalCycleRepository implements CycleRepository {
  LocalCycleRepository();

  // Starts null — a fresh install has no cycle data yet. It's only
  // populated once the user actually submits the onboarding form via
  // saveOnboarding(). Previously this was pre-seeded with sample data,
  // which made hasOnboarded true immediately and skipped onboarding
  // entirely.
  CycleData? _cycleData;

  final UserProfile _userProfile = const UserProfile(
    name: 'Aaki Prajapati',
    email: 'aaki@gmail.com',
    isPremium: false,
  );

  final List<MoodEntry> _moodEntries = [];

  static const _simulatedLatency = Duration(milliseconds: 600);

  @override
  Future<CycleData?> fetchCycleData() async {
    await Future.delayed(_simulatedLatency);
    return _cycleData;
  }

  @override
  Future<UserProfile> fetchUserProfile() async {
    await Future.delayed(_simulatedLatency);
    return _userProfile;
  }

  @override
  Future<List<MoodEntry>> fetchMoodEntries() async {
    await Future.delayed(_simulatedLatency);
    return List.unmodifiable(_moodEntries);
  }

  @override
  Future<void> saveOnboarding({
    required int averageCycleLengthDays,
    required DateTime lastPeriodStartDate,
  }) async {
    await Future.delayed(_simulatedLatency);
    if (averageCycleLengthDays <= 0) {
      throw ArgumentError('Cycle length must be greater than 0');
    }

    final existing = _cycleData;
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

    if (existing == null) {
      // First-time onboarding: create the initial CycleData from
      // scratch using what the user entered.
      _cycleData = CycleData(
        averageCycleLengthDays: averageCycleLengthDays,
        lastPeriodStartDate: lastPeriodStartDate,
        regularityPercent: 94,
        loggedDates: {...periodDates},
      );
    } else {
      // Re-onboarding / editing details later: keep existing
      // loggedDates (e.g. mood check-ins) and merge in the new period
      // range, updating the two changed fields.
      _cycleData = existing.copyWith(
        averageCycleLengthDays: averageCycleLengthDays,
        lastPeriodStartDate: lastPeriodStartDate,
        loggedDates: {...existing.loggedDates, ...periodDates},
      );
    }
  }

  @override
  Future<void> saveMoodEntry(MoodEntry entry) async {
    await Future.delayed(_simulatedLatency);
    _moodEntries.removeWhere((e) =>
    e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    _moodEntries.add(entry);

    final current = _cycleData;
    if (current != null) {
      final updatedLoggedDates = {...current.loggedDates, entry.date};
      _cycleData = current.copyWith(loggedDates: updatedLoggedDates);
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_simulatedLatency);
    _cycleData = null;
    _moodEntries.clear();
  }
}