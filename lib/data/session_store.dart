import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AuthSnapshot {
  const AuthSnapshot({required this.signedIn, this.userId});

  final bool signedIn;
  final String? userId;

  static const signedOut = AuthSnapshot(signedIn: false);
}

class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  static const _tokenKey = 'whimsical.jwt';
  static const _userIdKey = 'whimsical.uid';

  String? token;
  String? userId;

  final _controller = StreamController<AuthSnapshot>.broadcast();
  Stream<AuthSnapshot> get changes => _controller.stream;

  bool get signedIn => token != null && token!.isNotEmpty;

  AuthSnapshot get snapshot =>
      signedIn ? AuthSnapshot(signedIn: true, userId: userId) : AuthSnapshot.signedOut;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    userId = prefs.getString(_userIdKey);
    _controller.add(snapshot);
  }

  Future<void> save({required String newToken, required String newUserId}) async {
    token = newToken;
    userId = newUserId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    await prefs.setString(_userIdKey, newUserId);
    _controller.add(snapshot);
  }

  Future<void> clear() async {
    token = null;
    userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _controller.add(AuthSnapshot.signedOut);
  }
}
