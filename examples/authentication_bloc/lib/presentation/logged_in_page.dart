import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/authentication_bloc.dart';

class LoggedInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Logged In'),
          actions: [
            MaterialButton(
              child: Text(
                'Log out',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: context.read<AuthenticationBloc>().logout,
            )
          ],
        ),
        body: Center(
          child: Text(
              'You are logged in as a user with id: ${context.read<AuthenticationBloc>().state.user.id}'),
        ),
      );
}
