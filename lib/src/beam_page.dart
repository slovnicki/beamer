import 'package:flutter/widgets.dart';

class BeamPage extends Page {
  final String pathBlueprint;
  final Widget page;

  BeamPage({
    @required String pathBlueprint,
    @required this.page,
  })  : pathBlueprint = pathBlueprint,
        super(key: ValueKey(pathBlueprint));

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) => this.page,
      transitionsBuilder: (context, animation, animation2, widget) {
        return SlideTransition(
          position:
              animation.drive(Tween(begin: Offset(0, 1), end: Offset(0, 0))),
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
            child: widget,
          ),
        );
      },
    );
  }
}
