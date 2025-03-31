import 'dart:async';

import 'package:authentication_repository/src/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final supabase = Supabase.instance.client;
  AuthResponse? authReponse;

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
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
    String userId = authReponse?.user?.id ?? '';
    String userEmail = authReponse?.user?.email ?? '';
    return UserModel(id: userId, email: userEmail);
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
