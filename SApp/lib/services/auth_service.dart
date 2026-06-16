import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';


class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  Profile? _profile;
  bool _isLoading = false;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;

  User? get currentUser => _client.auth.currentUser;

  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated => currentUser != null;




  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================
  // SIGN IN
  // ==========================

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await fetchProfile();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================
  // SIGN UP
  // ==========================

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading(true);

      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId == null) {
        throw Exception('Failed to create user');
      }

      await _client.from('Profile').insert({
        'user': userId,
        'full_name': fullName ?? '',
        'workplace': '',
        'email_reminder': false,
        'daily_reminder': false,
      });

      await fetchProfile();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================
  // PROFILE
  // ==========================

  Future<void> fetchProfile() async {
    final userId = currentUserId;

    if (userId == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    final data = await _client
        .from('Profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    print(data);
    if (data == null) {
      _profile = null;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localSleep = prefs.getInt('${userId}_last_sleep_hours');
      final localBedtime = prefs.getString('${userId}_last_bedtime');

      final profileMap = Map<String, dynamic>.from(data);
      if (localSleep != null) {
        profileMap['sleep_hours'] = localSleep;
      }
      if (localBedtime != null) {
        profileMap['bedtime'] = localBedtime;
      }

      _profile = Profile.fromJson(profileMap);
    }

    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    required String workplace, required int sleepHours, required String bedtime,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${userId}_last_sleep_hours', sleepHours);
    await prefs.setString('${userId}_last_bedtime', bedtime);

    await _client
        .from('Profile')
        .update({
      'full_name': fullName,
      'workplace': workplace,
      'sleep_hours': sleepHours,
      'bedtime': bedtime,

    })
        .eq('user_id', userId);

    await fetchProfile();
  }


  // ==========================
  // PASSWORD RESET
  // ==========================

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ==========================
  // SIGN OUT
  // ==========================

  Future<void> signOut() async {
    await _client.auth.signOut();

    _profile = null;

    notifyListeners();
  }

  // ==========================
  // INITIAL LOAD
  // ==========================

  Future<void> initialize() async {
    if (currentUserId != null) {
      await fetchProfile();
    }
  }
}