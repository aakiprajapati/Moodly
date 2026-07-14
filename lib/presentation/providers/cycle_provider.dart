import 'package:flutter/foundation.dart';
import '../../data/models/cycle_data.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/cycle_repository.dart';
import 'view_state.dart';

/// Central app state: cycle data, user profile, and mood entries.
/// Every screen (Calendar, Log, Insights, Settings) listens to this
/// single provider via `context.watch` / `Consumer`, keeping state
/// management consistent across the app.
class CycleProvider extends ChangeNotifier {
  CycleProvider(this._repository);

  final CycleRepository _repository;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CycleData? _cycleData;
  CycleData? get cycleData => _cycleData;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  List<MoodEntry> _moodEntries = [];
  List<MoodEntry> get moodEntries => _moodEntries;

  bool get hasOnboarded => _cycleData != null;

  /// Loads cycle data, profile, and mood entries in parallel. Called
  /// once at app start (post-splash) and can be re-called to refresh.
  Future<void> loadInitialData() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchCycleData(),
        _repository.fetchUserProfile(),
        _repository.fetchMoodEntries(),
      ]);

      _cycleData = results[0] as CycleData;
      _userProfile = results[1] as UserProfile;
      _moodEntries = results[2] as List<MoodEntry>;

      _state = ViewState.loaded;
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Something went wrong while loading your data. '
          'Please try again.';
    }
    notifyListeners();
  }

  Future<bool> completeOnboarding({
    required int averageCycleLengthDays,
    required DateTime lastPeriodStartDate,
  }) async {
    try {
      await _repository.saveOnboarding(
        averageCycleLengthDays: averageCycleLengthDays,
        lastPeriodStartDate: lastPeriodStartDate,
      );
      _cycleData = await _repository.fetchCycleData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not save your details. Please check them and '
          'try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveMoodEntry(MoodEntry entry) async {
    try {
      await _repository.saveMoodEntry(entry);
      _moodEntries = await _repository.fetchMoodEntries();
      _cycleData = await _repository.fetchCycleData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not save your entry. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Today's entry, if one has already been logged, used to pre-fill
  /// the Log screen when the user revisits it the same day.
  MoodEntry? get todaysEntry {
    final today = DateTime.now();
    for (final entry in _moodEntries) {
      if (entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day) {
        return entry;
      }
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
