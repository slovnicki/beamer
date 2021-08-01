import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class Location1 extends BeamLocation<BeamState> {
  Location1([RouteInformation? routeInformation]) : super(routeInformation);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('l1'),
          child: Container(),
        ),
        if (state.pathBlueprintSegments.contains('one'))
          BeamPage(
            key: const ValueKey('l1-one'),
            child: Container(),
          ),
        if (state.pathBlueprintSegments.contains('two'))
          BeamPage(
            key: const ValueKey('l1-two'),
            child: Container(),
          )
      ];

  @override
  List<String> get pathPatterns => ['/l1/one', '/l1/two'];
}

class Location2 extends BeamLocation<BeamState> {
  Location2([RouteInformation? routeInformation]) : super(routeInformation);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('l2'),
          child: Container(),
        )
      ];

  @override
  List<String> get pathPatterns => ['/l2/:id'];
}

class CustomState with RouteInformationSerializable {
  CustomState({this.customVar = ''});

  final String customVar;

  @override
  CustomState fromRouteInformation(RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location ?? '/');
    if (uri.pathSegments.length > 1) {
      return CustomState(customVar: uri.pathSegments[1]);
    }
    return CustomState();
  }

  @override
  RouteInformation toRouteInformation() => RouteInformation(
        location: '/custom' + (customVar.isNotEmpty ? '/$customVar' : ''),
      );
}

class CustomStateLocation extends BeamLocation<CustomState> {
  CustomStateLocation([RouteInformation? routeInformation])
      : super(routeInformation);

  @override
  CustomState createState(RouteInformation routeInformation) =>
      CustomState().fromRouteInformation(routeInformation);

  @override
  List<String> get pathPatterns => ['/custom/:customVar'];

  @override
  List<BeamPage> buildPages(BuildContext context, CustomState state) => [
        BeamPage(
          key: ValueKey('custom-${state.customVar}'),
          child: Container(),
        )
      ];
}

class NoStateLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/page'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('page'),
          child: Container(),
        )
      ];
}

class RegExpLocation extends BeamLocation<BeamState> {
  RegExpLocation([RouteInformation? routeInformation])
      : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => [RegExp('/reg')];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('reg'),
          child: Container(),
        )
      ];
}

class AsteriskLocation extends BeamLocation<BeamState> {
  AsteriskLocation([RouteInformation? routeInformation])
      : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => ['/anything/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('anything'),
          child: Container(),
        )
      ];
}
