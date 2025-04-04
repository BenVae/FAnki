import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fanki/pages/login/login.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<InitializeLogin>(_initializeLoginPage);
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  final AuthenticationRepository _authenticationRepository;

  void _initializeLoginPage(InitializeLogin event, Emitter<LoginState> emit) {
    Email email = Email.dirty('w@w.de');

    emit(
      state.copyWith(
        email: email,
        password: Password.pure(),
        isValid: Formz.validate([email]),
      ),
    );
  }

  void _onUsernameChanged(
      LoginUsernameChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.username);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.password, email]),
      ),
    );
  }

  void _onPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([password, state.email]),
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _authenticationRepository.logInWithEmailAndPassword(
          email: state.email.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }

  void _onSignUpButtonPressed(
      SignUpButtonPressed event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: FormzSubmissionStatus.success));
  }
}
