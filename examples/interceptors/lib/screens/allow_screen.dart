import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:interceptors/main.dart';

class AllowScreen extends StatelessWidget {
  const AllowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeamInterceptorPopScope(
      interceptors: [allowNavigatingInterceptor],
      beamerDelegate: beamerDelegate,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.beamToNamed('/block-this-route');

                  ScaffoldMessenger.of(beamerDelegate.navigator.context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(beamerDelegate.navigator.context).showSnackBar(
                    const SnackBar(content: Text('This route is NOT intercepted and thus NOT blocked.')),
                  );
                },
                child: const Text('Go to /block-this-route (not blocked)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go to back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
