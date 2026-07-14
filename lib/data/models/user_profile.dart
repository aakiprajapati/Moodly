import 'package:flutter/foundation.dart';

/// Basic user/account info shown on the Settings screen.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.isPremium = false,
    this.avatarAsset,
  });

  final String name;
  final String email;
  final bool isPremium;
  final String? avatarAsset;

  UserProfile copyWith({
    String? name,
    String? email,
    bool? isPremium,
    String? avatarAsset,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}
