import 'package:fanki/pages/sign_up/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  void _listenForSignUpStatus(BuildContext context, SignUpState state) {
    if (state.status == SignUpStatus.failure && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    } else if (state.status == SignUpStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) => _listenForSignUpStatus(context, state),
          builder: (context, state) {
            final bloc = context.read<SignUpBloc>();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Email TextField
                  TextField(
                    key: const Key('signUp_emailField'),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: !state.isValidEmail && state.email.isNotEmpty
                          ? 'Invalid email'
                          : null,
                    ),
                    onChanged: (value) => bloc.add(EmailChanged(value)),
                  ),
                  const SizedBox(height: 16),
                  // Password TextField
                  TextField(
                    key: const Key('signUp_passwordField'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText:
                          !state.isValidPassword && state.password.isNotEmpty
                              ? 'At least 6 characters'
                              : null,
                    ),
                    obscureText: true,
                    onChanged: (value) => bloc.add(PasswordChanged(value)),
                  ),
                  const SizedBox(height: 24),
                  // Sign Up Button
                  ElevatedButton(
                    onPressed: state.status == SignUpStatus.submitting
                        ? null
                        : () => bloc.add(SignUpSubmitted()),
                    child: state.status == SignUpStatus.submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign Up'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
