import 'package:beamer/beamer.dart';
import 'package:deep_links/authenticator.dart';
import 'package:deep_links/screens.dart';

late final BeamerDelegate beamerDelegate;

void createBeamerDelegate() {
  beamerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/splash': (_, __, ___) => const SplashScreen(),
        '/login': (_, __, ___) => const LoginScreen(),
        '/home': (_, __, ___) => const HomeScreen(),
        '/home/deeper': (_, __, ___) => const DeeperScreen(),
      },
    ),
    updateListenable: authenticator,
    guards: [
      BeamGuard(
        pathPatterns: ['/splash'],
        check: (_, __) => authenticator.isLoading,
        beamToNamed: (_, __, deepLink) =>
            authenticator.isAuthenticated ? (deepLink ?? '/home') : '/login',
      ),
      BeamGuard(
        pathPatterns: ['/login'],
        check: (_, __) => authenticator.isNotAuthenticated,
        beamToNamed: (_, __, deepLink) =>
            authenticator.isAuthenticated ? (deepLink ?? '/home') : '/splash',
      ),
      BeamGuard(
        pathPatterns: ['/splash', '/login'],
        guardNonMatching: true,
        check: (_, __) => authenticator.isAuthenticated,
        beamToNamed: (_, __, ___) =>
            authenticator.isNotAuthenticated ? '/login' : '/splash',
      ),
    ],
  );
}
