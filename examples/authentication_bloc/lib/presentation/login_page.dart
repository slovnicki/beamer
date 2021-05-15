import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: BlocProvider(
          create: (context) => LoginBloc(
            authenticationRepository:
                RepositoryProvider.of<AuthenticationRepository>(context),
          ),
          child: Center(child: LoginForm()),
        ),
      );
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure)
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Authentication Failure'),
              ),
            );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 256),
        child: AutofillGroup(
          child: Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              FlutterLogo(size: 128),
              Text(
                'Login',
                style: Theme.of(context).textTheme.headline2,
              ),
              _UsernameInput(
                email: context.read<LoginBloc>().state.username.value,
              ),
              _PasswordInput(
                password: context.read<LoginBloc>().state.password.value,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _LoginButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  final TextEditingController _controller;

  _UsernameInput({Key? key, String? email})
      : _controller = TextEditingController(text: email),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = context.select((LoginBloc bloc) => bloc.state.username);
    return TextField(
      key: const Key('loginForm_usernameInput_textField'),
      controller: _controller,
      autofillHints: [AutofillHints.email, AutofillHints.username],
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onChanged: (username) =>
          context.read<LoginBloc>().add(LoginUsernameChanged(username.trim())),
      decoration: InputDecoration(
        hintText: 'Username',
        errorText: username.invalid ? 'Invalid username' : null,
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController _controller;

  _PasswordInput({Key? key, String? password})
      : _controller = TextEditingController(text: password),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final password = context.select((LoginBloc bloc) => bloc.state.password);
    return TextField(
      key: const Key('loginForm_passwordInput_textField'),
      controller: _controller,
      autofillHints: [AutofillHints.password],
      onChanged: (password) =>
          context.read<LoginBloc>().add(LoginPasswordChanged(password)),
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        errorText: password.invalid ? 'Invalid password' : null,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final status = context.select((LoginBloc bloc) => bloc.state.status);
    return Center(
      child: status.isSubmissionInProgress
          ? const CircularProgressIndicator()
          : ElevatedButton(
              key: const Key('loginForm_continue_raisedButton'),
              child: const Text('Login'),
              onPressed: status.isValidated
                  ? () => context.read<LoginBloc>().add(const LoginSubmitted())
                  : null,
            ),
    );
  }
}
