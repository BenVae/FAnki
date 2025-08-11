import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';

final _logger = getLogger('LoginCubit');

class LoginCubitV2 extends Cubit<LoginState> {
  final AuthenticationRepository _authenticationRepository;
  final CardDeckManager _cdm;
  final DeckTreeManager _deckTreeManager;

  LoginCubitV2(
    this._authenticationRepository,
    this._cdm,
    this._deckTreeManager,
  ) : super(LoginLoading()) {
    _logger.config('Initializing LoginCubitV2 - CDM userID: "${_cdm.userID}"');
    if (_authenticationRepository.currentUser.isEmpty) {
      _logger.info('Current user is empty, showing login screen');
      emit(LoginInitial());
    } else {
      _logger.info('Current user found, setting up authentication');
      String email = _authenticationRepository.currentUser.email ?? '';
      _logger.fine('Retrieved email from current user: "$email"');
      if (email != '') {
        _logger.info('Setting userID in deck managers');
        _cdm.setUserID(email);
        _deckTreeManager.setUserId(email);
        _logger.fine('UserID set successfully - CDM userID: "${_cdm.userID}"');
        emit(LoginSuccess());
      } else {
        _logger.severe('Failed to get email from authenticated user');
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
      _logger.info('User login successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      _logger.warning('User login failed: ${error.toString()}');
    }
  }

  void logout() async {
    emit(LoginLoading());
    try {
      await _authenticationRepository.logOut();
      emit(LoginInitial());
      _logger.info('User logout successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      _logger.warning('User logout failed: ${error.toString()}');
    }
  }

  void signup(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authenticationRepository.signUp(email: email, password: password);
      emit(LoginSuccess());
      _cdm.setUserID(email);
      await _deckTreeManager.setUserId(email);
      _logger.info('User signup successful');
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
      _logger.warning('User signup failed: ${error.toString()}');
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