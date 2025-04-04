part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

// Fired whenever the user changes the email text field
class EmailChanged extends SignUpEvent {
  final String email;
  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

// Fired whenever the user changes the password text field
class PasswordChanged extends SignUpEvent {
  final String password;
  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

// Fired when the user taps the "Sign Up" button
class SignUpSubmitted extends SignUpEvent {}
