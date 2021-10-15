import 'package:authentication_riverpod/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: 'beamer');
    final passwordController = useTextEditingController(text: 'supersecret');

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 256),
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
              UsernameInput(controller: usernameController),
              PasswordInput(controller: passwordController),
              LoginButton(
                  usernameController: usernameController,
                  passwordController: passwordController),
              Text('STATE: ${authState.status}')
            ],
          ),
        ),
      ),
    );
  }
}

class UsernameInput extends StatelessWidget {
  final TextEditingController controller;

  const UsernameInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: 'Username',
          border: OutlineInputBorder(),
          hintText: 'beamer'),
    );
  }
}

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      controller: controller,
      decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
          hintText: 'supersecret'),
    );
  }
}

class LoginButton extends ConsumerWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginButton(
      {Key? key,
      required this.usernameController,
      required this.passwordController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await ref
              .read(authProvider.notifier)
              .loginUser(usernameController.text, passwordController.text);
        },
        child: Text('Login'),
      ),
    );
  }
}
