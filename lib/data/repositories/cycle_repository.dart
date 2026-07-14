import '../models/cycle_data.dart';
import '../models/mood_entry.dart';
import '../models/user_profile.dart';

/// Abstract data source contract. Swapping [LocalCycleRepository] for a
/// Firestore/REST-backed implementation later only requires implementing
/// this interface — presentation code never changes.
abstract class CycleRepository {
  Future<CycleData> fetchCycleData();
  Future<UserProfile> fetchUserProfile();
  Future<List<MoodEntry>> fetchMoodEntries();
  Future<void> saveOnboarding({
    required int averageCycleLengthDays,
    required DateTime lastPeriodStartDate,
  });
  Future<void> saveMoodEntry(MoodEntry entry);
}

/// In-memory implementation used for this coursework build. Simulates
/// realistic network latency (and can simulate failure) so loading and
/// error states in the UI are exercised rather than dead code paths.
class LocalCycleRepository implements CycleRepository {
  LocalCycleRepository();

  CycleData _cycleData = CycleData(
    averageCycleLengthDays: 28,
    lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 7)),
    regularityPercent: 94,
    loggedDates: {
      DateTime.now().subtract(const Duration(days: 6)),
      DateTime.now().subtract(const Duration(days: 5)),
    },
  );

  final UserProfile _userProfile = const UserProfile(
    name: 'Aaki Prajapati',
    email: 'aaki@gmail.com',
    isPremium: false,
  );

  final List<MoodEntry> _moodEntries = [];

  static const _simulatedLatency = Duration(milliseconds: 600);

  @override
  Future<CycleData> fetchCycleData() async {
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
    _cycleData = _cycleData.copyWith(
      averageCycleLengthDays: averageCycleLengthDays,
      lastPeriodStartDate: lastPeriodStartDate,
    );
  }

  @override
  Future<void> saveMoodEntry(MoodEntry entry) async {
    await Future.delayed(_simulatedLatency);
    _moodEntries.removeWhere((e) =>
    e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    _moodEntries.add(entry);

    final updatedLoggedDates = {..._cycleData.loggedDates, entry.date};
    _cycleData = _cycleData.copyWith(loggedDates: updatedLoggedDates);
  }
}
