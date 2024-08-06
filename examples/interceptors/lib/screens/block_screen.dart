import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:interceptors/main.dart';

class BlockScreen extends StatelessWidget {
  const BlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeamInterceptorPopScope(
      interceptors: [
        blockNavigatingInterceptor,
      ],
      beamerDelegate: beamerDelegate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              context.beamToNamed('/block-this-route');

              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(beamerDelegate.navigator.context).removeCurrentSnackBar();
                ScaffoldMessenger.of(beamerDelegate.navigator.context).showSnackBar(
                  const SnackBar(content: Text('This route is intercepted and thus blocked.')),
                );
              });
            },
            child: const Text('Go to blocked route'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go to back'),
          ),
        ],
      ),
    );
  }
}
