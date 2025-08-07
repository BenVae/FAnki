import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';

class LoginCubitV2 extends Cubit<LoginState> {
  final AuthenticationRepository _authenticationRepository;
  final CardDeckManager _cdm;
  final DeckTreeManager _deckTreeManager;

  LoginCubitV2(
    this._authenticationRepository,
    this._cdm,
    this._deckTreeManager,
  ) : super(LoginLoading()) {
    if (_authenticationRepository.currentUser.isEmpty) {
      log.info('CurrentUser empty');
      emit(LoginInitial());
    } else {
      log.info('CurrentUser not empty');
      String email = _authenticationRepository.currentUser.email ?? '';
      if (email != '') {
        _cdm.setUserID(email);
        _deckTreeManager.setUserId(email);
        emit(LoginSuccess());
      } else {
        log.severe('Did not get the email from auth.');
        emit(LoginInitial());
      }
    }
  }

  void login(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
          email: email, password: password);
      emit(LoginSuccess());
      _cdm.setUserID(email);
      await _deckTreeManager.setUserId(email);
      log.info('Login successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      log.info('Login failed');
    }
  }

  void logout() async {
    emit(LoginLoading());
    try {
      await _authenticationRepository.logOut();
      emit(LoginInitial());
      log.info('Logout successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      log.info('Logout failed');
    }
  }

  void signup(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authenticationRepository.signUp(email: email, password: password);
      emit(LoginSuccess());
      _cdm.setUserID(email);
      await _deckTreeManager.setUserId(email);
      log.info('Signup successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      log.info('Signup failed');
    }
  }
}

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}