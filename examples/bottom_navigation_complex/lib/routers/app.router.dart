import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/routers/locations/layout.locations.dart';
import 'package:bottom_navigation_complex/routers/locations/settings.locations.dart';

final BeamerDelegate routerDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Books',
  routeListener: (_, delegate) {
    print("${'=' * 15} History ${'=' * 15}");
    delegate.beamingHistory.asMap().entries.forEach((beamHistory) {
      for (var history in beamHistory.value.history) {
        print('beamlocation ${beamHistory.key}: \t path: ${history.routeInformation.location}');
      }
    });
  },
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      LayoutLocation(),
      SettingsLocation(),
    ],
  ),
);
