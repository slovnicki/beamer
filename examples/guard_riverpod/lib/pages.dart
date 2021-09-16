import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guard_riverpod/locations.dart';

class FirstPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('FirstPage')),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Disable next page guard'),
            Switch(
              value: ref.watch(navigationProvider).state,
              onChanged: (enabled) => ref.read(navigationProvider).state = enabled,
            ),
            ElevatedButton(
              onPressed: () {
                  if (!ref.read(navigationProvider).state) {
                    final snack = SnackBar(content: Text('Please, disable the navigation guard first'));
                    ScaffoldMessenger.of(context).showSnackBar(snack);
                  }

                context.beamToNamed('/$firstRoute/$secondRoute');
              },
              child: Text('Navigate to SecondPage'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SecondPage')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamBack(),
          child: Text('Go back to FirstPage'),
        ),
      ),
    );
  }
}