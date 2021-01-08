import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class Beamer extends InheritedWidget {
  Beamer({
    this.routerDelegate,
    @required Widget child,
  }) : super(child: child);

  final BeamerRouterDelegate routerDelegate;

  static BeamerRouterDelegate of(BuildContext context) {
    final Beamer beamer = context.dependOnInheritedWidgetOfExactType<Beamer>();
    if (beamer != null && beamer.routerDelegate != null) {
      return beamer.routerDelegate;
    }
    return Router.of(context).routerDelegate;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
