import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthenticationRepository _authenticationRepository;

  SignUpBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const SignUpState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<SignUpState> emit) {
    emit(
      state.copyWith(email: event.email),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<SignUpState> emit) {
    emit(
      state.copyWith(password: event.password),
    );
  }

  Future<void> _onSignUpSubmitted(SignUpSubmitted event, Emitter<SignUpState> emit) async {
    // Start submitting
    emit(state.copyWith(status: SignUpStatus.submitting, errorMessage: null));

    // Validate
    if (!state.isValidEmail) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: "Invalid email format",
      ));
      return;
    }

    if (!state.isValidPassword) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: "Password must be at least 6 characters",
      ));
      return;
    }

    try {
      _authenticationRepository.signUpWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: "Sign up failed. Please try again.",
      ));
    }
  }
}
