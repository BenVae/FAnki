import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fanki/pages/login/login.dart';
import 'package:formz/formz.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final initialUsername = context.read<LoginBloc>().state.email.value;
    final initialPassword = context.read<LoginBloc>().state.password.value;
    _emailController = TextEditingController(text: initialUsername);
    _passwordController = TextEditingController(text: initialPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.email.value != current.email.value ||
            previous.status.isFailure != current.status.isFailure,
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Authentication Failure')),
              );
          }
          if (_emailController.text != state.email.value) {
            _emailController.text = state.email.value;
            _passwordController.text = state.password.value;
          }
        },
        builder: (context, state) {
          return Align(
            alignment: const Alignment(0, -1 / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset(
                //   'assets/bloc_logo_small.png',
                //   height: 120,
                // ),
                TextFormField(
                  key: const Key('loginForm_usernameInput_textField'),
                  controller: _emailController,
                  onChanged: (username) {
                    context
                        .read<LoginBloc>()
                        .add(LoginUsernameChanged(username));
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.email.displayError != null
                        ? 'invalid username'
                        : null,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(12)),
                TextField(
                  key: const Key('loginForm_passwordInput_textField'),
                  controller: _passwordController,
                  onChanged: (password) {
                    context
                        .read<LoginBloc>()
                        .add(LoginPasswordChanged(password));
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: state.password.displayError != null
                        ? 'invalid password'
                        : null,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(12)),
                _LoginButton(),
              ],
            ),
          );
        });
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgressOrSuccess = context.select(
      (LoginBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) return const CircularProgressIndicator();

    final isValid = context.select((LoginBloc bloc) => bloc.state.isValid);

    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      onPressed: isValid
          ? () => context.read<LoginBloc>().add(const LoginSubmitted())
          : null,
      child: const Text('Login'),
    );
  }
}
