import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/routers/locations/layout.locations.dart';
import 'package:bottom_navigation_complex/screens/book_details.screen.dart';
import 'package:flutter/widgets.dart';

class BookLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/Book/:bookID'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        ...LayoutLocation().buildPages(context, state),
        if (state.pathParameters.containsKey('bookID'))
          BeamPage(
            key: ValueKey('book-details-${state.pathParameters["bookID"]}'),
            child: BookDetailsScreen(bookID: state.pathParameters["bookID"]!),
          )
      ];
}
