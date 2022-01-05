import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guard_riverpod/locations.dart';

class FirstPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listening won't rebuild this widget, but will make sure that we can
    // call functions independently from this widget's lifecycle.
    ref.listen<StateController<bool>>(navigationToThirdProvider.state,
        (prev, next) {
      // We will only navigate when our provider state is `true`.
      if (next.state) {
        context.beamToNamed('/$firstRoute/$thirdRoute');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('FirstPage')),
      body: Container(
        padding: EdgeInsets.all(40),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Tap to enable/disable SecondPage guard'),
            Switch(
              value: ref.watch(navigationToSecondProvider),
              onChanged: (enabled) =>
                  ref.read(navigationToSecondProvider.notifier).state = enabled,
            ),
            ElevatedButton(
              onPressed: () {
                if (!ref.read(navigationToSecondProvider)) {
                  final snack = SnackBar(
                      content:
                          Text('Please, disable the navigation guard first'));
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                }

                context.beamToNamed('/$firstRoute/$secondRoute');
              },
              child: Text('Navigate to SecondPage'),
            ),
            SizedBox(height: 20),
            Divider(thickness: 2),
            SizedBox(height: 20),
            Text(
                'Will trigger a navigation to ThirdPage when switching to enabled'),
            Switch(
              value: ref.watch(navigationToThirdProvider),
              onChanged: (enabled) =>
                  ref.read(navigationToThirdProvider.notifier).state = enabled,
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

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ThirdPage')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamBack(),
          child: Text('Go back to FirstPage'),
        ),
      ),
    );
  }
}
