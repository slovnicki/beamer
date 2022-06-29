import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/routers/locations/article.location.dart';
import 'package:bottom_navigation_complex/routers/locations/book.location.dart';
import 'package:bottom_navigation_complex/routers/locations/layout.locations.dart';
import 'package:bottom_navigation_complex/routers/locations/settings.locations.dart';

final BeamerDelegate routerDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Books',
  routeListener: (_, delegate) {
    print("${'=' * 15} History ${'=' * 15}");
    for (var beamHistory in delegate.beamingHistory) {
      for (var history in beamHistory.history) {
        print('BeamLocation: ${beamHistory.runtimeType} \t path: ${history.routeInformation.location}');
      }
    }
  },
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      LayoutLocation(),
      BookLocation(),
      ArticleLocation(),
      SettingsLocation(),
    ],
  ),
);
