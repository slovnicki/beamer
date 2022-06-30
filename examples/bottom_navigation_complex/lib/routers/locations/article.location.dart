import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/routers/locations/layout.locations.dart';
import 'package:bottom_navigation_complex/screens/article_details.screen.dart';
import 'package:flutter/widgets.dart';
import 'package:bottom_navigation_complex/routers/app.router.dart';

class ArticleLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/Article/:articleID'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        ...LayoutLocation().buildPages(context, state),
        if (state.pathParameters.containsKey('articleID'))
          BeamPage(
            key: ValueKey('article-details-${state.pathParameters["articleID"]}'),
            child: ArticleDetailsScreen(articleID: state.pathParameters["articleID"]!),
            popToNamed: previousLocation,
          )
      ];
}
