import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/screens/articles.screen.dart';
import 'package:flutter/foundation.dart';

final BeamerDelegate articlesRouterDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Articles',
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/Articles': (context, state, data) => const BeamPage(key: ValueKey('articles'), child: ArticleScreen()),
    },
  ),
);
