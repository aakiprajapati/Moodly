import 'package:flutter/material.dart';

/// The six moods a user can log on the Daily Check-in screen.
enum MoodType {
  happy(label: 'Happy', icon: Icons.sentiment_satisfied_alt),
  tired(label: 'Tired', icon: Icons.bedtime_outlined),
  anxious(label: 'Anxious', icon: Icons.waves),
  calm(label: 'Calm', icon: Icons.spa_outlined),
  irritated(label: 'Irritated', icon: Icons.cloud_outlined),
  angry(label: 'Angry', icon: Icons.sentiment_very_dissatisfied);

  const MoodType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Physical/cycle symptoms selectable on the Daily Check-in screen.
enum Symptom {
  headache('Headache'),
  cramps('Cramps'),
  fatigue('Fatigue'),
  nausea('Nausea'),
  bloating('Bloating'),
  insomnia('Insomnia'),
  backAche('Back ache'),
  brainFog('Brain Fog');

  const Symptom(this.label);

  final String label;
}

/// A single day's check-in: mood, symptoms, and free-form notes.
@immutable
class MoodEntry {
  const MoodEntry({
    required this.date,
    this.mood,
    this.symptoms = const {},
    this.notes = '',
  });

  final DateTime date;
  final MoodType? mood;
  final Set<Symptom> symptoms;
  final String notes;

  MoodEntry copyWith({
    DateTime? date,
    MoodType? mood,
    Set<Symptom>? symptoms,
    String? notes,
  }) {
    return MoodEntry(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }

  bool get isEmpty => mood == null && symptoms.isEmpty && notes.trim().isEmpty;
}
