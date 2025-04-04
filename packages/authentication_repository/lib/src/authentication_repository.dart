import 'dart:async';

import 'package:authentication_repository/src/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final supabase = Supabase.instance.client;
  AuthResponse? authReponse;

  AuthenticationRepository() {
    _initialize();
  }

  void _initialize() {
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        _controller.add(AuthenticationStatus.unauthenticated);
      } else {
        _controller.add(AuthenticationStatus.authenticated);
      }
    });
  }

  Stream<AuthenticationStatus> get status async* {
    final session = supabase.auth.currentSession;

    if (session != null) {
      yield AuthenticationStatus.authenticated;
    } else {
      yield AuthenticationStatus.unauthenticated;
    }

    yield* _controller.stream;
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    authReponse = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (authReponse?.user != null) {
      _controller.add(AuthenticationStatus.authenticated);
    } else {
      _controller.add(AuthenticationStatus.unauthenticated);
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    authReponse = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthenticationStatus.authenticated),
    );
  }

  UserModel getUser() {
    final user = supabase.auth.currentUser;
    String userId = user?.id ?? '';
    String userEmail = user?.email ?? '';
    return UserModel(id: userId, email: userEmail);
  }

  Future<void> logOut() async {
    await supabase.auth.signOut();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
