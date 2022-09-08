import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('nested navigation', () {
    testWidgets(
        'nested navigation does not crash, when child is removed from widget tree',
        (tester) async {
      final routerDelegate = BeamerDelegate(
        initialPath: '/home',
        notFoundRedirectNamed: '/home',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state, data) => const MainLocation(),
          },
        ),
      );

      final authenticationNotifier = AuthenticationNotifier(
        child: MaterialApp.router(
            routeInformationParser: BeamerParser(),
            routerDelegate: routerDelegate,
            backButtonDispatcher:
                BeamerBackButtonDispatcher(delegate: routerDelegate)),
      );

      await tester.pumpWidget(MyApp(authenticationNotifier));

      expect(
          (routerDelegate.currentBeamLocation.state as BeamState)
              .pathPatternSegments
              .first,
          'home');
      authenticationNotifier.isUserAuthenticated = false;
      authenticationNotifier.isAuthenticatedStreamController.add(false);

      await tester.pumpAndSettle();
      expect(
          (routerDelegate.currentBeamLocation.state as BeamState)
              .pathPatternSegments
              .first,
          'login');

      authenticationNotifier.isUserAuthenticated = true;
      authenticationNotifier.isAuthenticatedStreamController.add(true);

      await tester.pumpAndSettle();
      expect(
          (routerDelegate.currentBeamLocation.state as BeamState)
              .pathPatternSegments
              .first,
          'home');
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp(this._authenticationNotifier, {Key? key}) : super(key: key);

  final AuthenticationNotifier _authenticationNotifier;

  @override
  Widget build(BuildContext context) {
    return _authenticationNotifier;
  }
}

class MainLocation extends StatefulWidget {
  const MainLocation({Key? key}) : super(key: key);

  @override
  State<MainLocation> createState() => _MainLocationState();
}

class _MainLocationState extends State<MainLocation> {
  StreamSubscription? subscription;

  final routerDelegate = BeamerDelegate(
      guards: [
        BeamGuard(
            pathPatterns: ['/login'],
            guardNonMatching: true,
            check: (context, state) =>
                AuthenticationNotifier.of(context).isUserAuthenticated,
            beamToNamed: (origin, target, _) => '/login')
      ],
      clearBeamingHistoryOn: {
        '/login'
      },
      updateParent: false,
      locationBuilder: RoutesLocationBuilder(routes: {
        '/home': (context, state, data) =>
            const SomePage(key: ValueKey('home'), text: 'Home'),
        '/login': (context, state, data) =>
            const SomePage(key: ValueKey('login'), text: 'Login')
      }));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription?.cancel();
    final authenticationNotifier = AuthenticationNotifier.of(context);
    subscription = authenticationNotifier.isAuthenticatedStreamController.stream
        .listen((element) {
      if (authenticationNotifier.isUserAuthenticated) {
        context.beamToNamed('/home');
      } else {
        context.beamToNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Beamer(routerDelegate: routerDelegate);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

class SomePage extends StatelessWidget {
  const SomePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(text)));
  }
}

// ignore: must_be_immutable
class AuthenticationNotifier extends InheritedWidget {
  AuthenticationNotifier({Key? key, required Widget child})
      : super(key: key, child: child);

  final StreamController<bool> isAuthenticatedStreamController =
      StreamController<bool>.broadcast();

  bool isUserAuthenticated = true;

  static AuthenticationNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AuthenticationNotifier>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
