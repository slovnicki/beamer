import 'package:flutter/widgets.dart';

import 'beamer_router_delegate.dart';

class Beamer extends StatelessWidget {
  Beamer({
    this.routerDelegate,
    @required this.child,
  });

  final BeamerRouterDelegate routerDelegate;
  final Widget child;

  static BeamerRouterDelegate of(BuildContext context) {
    final Beamer beamer = context.findAncestorWidgetOfExactType<Beamer>();
    if (beamer != null && beamer.routerDelegate != null) {
      return beamer.routerDelegate;
    }
    return Router.of(context).routerDelegate;
  }

  @override
  Widget build(BuildContext context) => child;
}
