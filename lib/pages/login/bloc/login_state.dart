part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final bool isValid;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }

  factory LoginState.fromJson(Map<String, dynamic> json) {
    return LoginState(
      status: FormzSubmissionStatus.values[json['status'] as int],
      email: Email.dirty(json['email'] as String),
      password: Password.dirty(json['password'] as String),
      isValid: json['isValid'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.index,
      'email': email.value,
      'password': password.value,
      'isValid': isValid,
    };
  }

  @override
  List<Object> get props => [status, email, password];
}
