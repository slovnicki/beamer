import 'package:authentication_riverpod/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          MaterialButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logoutUser();
            },
            child: Text(
              'Log out',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text('User: ${authState.user}'),
        ),
      ),
    );
  }
}
