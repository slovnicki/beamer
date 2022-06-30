import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/screens/article_details.screen.dart';
import 'package:bottom_navigation_complex/screens/articles.screen.dart';
import 'package:flutter/foundation.dart';
import 'package:bottom_navigation_complex/routers/app.router.dart';

final BeamerDelegate articlesRouterDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Articles',
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/Articles': (context, state, data) => const BeamPage(key: ValueKey('articles'), child: ArticlesScreen()),
      '/Articles/:articleID': (context, state, data) => BeamPage(
            key: ValueKey('articles-${state.pathParameters["articleID"]}'),
            child: ArticleDetailsScreen(articleID: state.pathParameters["articleID"]!),
            popToNamed: previousLocation,
          ),
    },
  ),
);
