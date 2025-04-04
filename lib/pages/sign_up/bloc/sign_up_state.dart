part of 'sign_up_bloc.dart';

enum SignUpStatus {
  initial,
  submitting,
  success,
  failure,
}

class SignUpState extends Equatable {
  final String email;
  final String password;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.email = '',
    this.password = '',
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  // Simple check for email validity
  bool get isValidEmail => email.contains('@');

  // Simple check for password validity
  bool get isValidPassword => password.length >= 6;

  SignUpState copyWith({
    String? email,
    String? password,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}
