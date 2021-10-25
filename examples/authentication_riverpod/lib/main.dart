import 'package:authentication_riverpod/beamer_locations.dart';
import 'package:authentication_riverpod/providers/auth_notifier.dart';
import 'package:authentication_riverpod/providers/provider.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  final routerDelegate = BeamerDelegate(
    guards: [
      /// if the user is authenticated
      /// else send them to /login
      BeamGuard(
          pathPatterns: ['/home'],
          check: (context, state) {
            final container = ProviderScope.containerOf(context, listen: false);
            return container.read(authProvider).status ==
                AuthStatus.authenticated;
          },
          beamToNamed: (_, __) => '/login'),

      /// if the user is anything other than authenticated
      /// else send them to /home
      BeamGuard(
          pathPatterns: ['/login'],
          check: (context, state) {
            final container = ProviderScope.containerOf(context, listen: false);
            return container.read(authProvider).status !=
                AuthStatus.authenticated;
          },
          beamToNamed: (_, __) =>'/home'),
    ],
    initialPath: '/login',
    locationBuilder: (routeInformation, _) => BeamerLocations(routeInformation),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// this is required so the `BeamGuard` checks can be rechecked on
    /// auth state changes
    ref.watch(authProvider);

    return BeamerProvider(
      routerDelegate: routerDelegate,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
      ),
    );
  }
}
