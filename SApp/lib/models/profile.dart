import 'package:flutter/material.dart';

class Profile {
  final String user;
  final String fullName;
  final String workplace;
  final Duration sleepHours;
  final TimeOfDay bedtime;

  const Profile({
    required this.user,
    required this.fullName,
    required this.workplace,
    required this.sleepHours,
    required this.bedtime,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final bedtimeString =
        json['bedtime'] as String? ?? '23:00';

    final parts = bedtimeString.split(':');

    return Profile(
      user: json['user'] ?? '',
      fullName: json['full_name'] ?? '',
      workplace: 'Keys: ${json.keys.toList()}',
      sleepHours: Duration(hours: json['sleep_hours'] ?? 8),
      bedtime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'full_name': fullName,
      'workplace': workplace,
      'sleep_hours': sleepHours,
      'bedtime':
      '${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')}',
    };
  }
}