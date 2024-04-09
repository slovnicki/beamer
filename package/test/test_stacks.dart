import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class Stack1 extends BeamStack<BeamState> {
  Stack1([RouteInformation? routeInformation]) : super(routeInformation);

  bool get doesHaveListeners => hasListeners;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('l1'),
          child: Container(),
        ),
        if (state.pathPatternSegments.contains('one'))
          BeamPage(
            key: const ValueKey('l1-one'),
            child: Container(),
          ),
        if (state.pathPatternSegments.contains('two'))
          BeamPage(
            key: const ValueKey('l1-two'),
            child: Container(),
          )
      ];

  @override
  List<String> get pathPatterns => ['/l1/one', '/l1/two'];
}

class Stack2 extends BeamStack<BeamState> {
  Stack2([RouteInformation? routeInformation]) : super(routeInformation);

  bool get doesHaveListeners => hasListeners;

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
    final uri = routeInformation.uri;
    if (uri.pathSegments.length > 1) {
      return CustomState(customVar: uri.pathSegments[1]);
    }
    return CustomState();
  }

  @override
  RouteInformation toRouteInformation() => RouteInformation(
        uri: Uri.parse('/custom' + (customVar.isNotEmpty ? '/$customVar' : '')),
      );
}

class CustomStateStack extends BeamStack<CustomState> {
  CustomStateStack([RouteInformation? routeInformation])
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

class NoStateStack extends BeamStack<BeamState> {
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

class RegExpStack extends BeamStack<BeamState> {
  RegExpStack([RouteInformation? routeInformation]) : super(routeInformation);

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

class AsteriskStack extends BeamStack<BeamState> {
  AsteriskStack([RouteInformation? routeInformation]) : super(routeInformation);

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

class StrictPatternsStack extends BeamStack<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/strict', '/strict/deeper'];

  @override
  bool get strictPathPatterns => true;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: const ValueKey('strict'),
        child: Container(),
      ),
      if (state.pathPatternSegments.contains('deeper'))
        BeamPage(
          key: const ValueKey('deeper'),
          child: Container(),
        ),
    ];
  }
}

class UpdateStateStub extends Mock {
  void call();
}

class UpdateStateStubBeamStack extends BeamStack {
  UpdateStateStubBeamStack(this.updateStateStub) : super();

  final UpdateStateStub updateStateStub;

  @override
  List<Pattern> get pathPatterns => ['*'];

  @override
  List<BeamPage> buildPages(
          BuildContext context, RouteInformationSerializable state) =>
      [BeamPage.notFound];

  @override
  void updateState(RouteInformation routeInformation) {
    super.updateState(routeInformation);
    updateStateStub.call();
  }
}

class SimpleBeamStack extends BeamStack<BeamState> {
  @override
  List<Pattern> get pathPatterns => [
        '/',
        '/route',
        '/route/deeper',
      ];

  @override
  List<BeamPage> buildPages(
    BuildContext context,
    BeamState state,
  ) =>
      [
        BeamPage(
          key: const ValueKey('/'),
          child: Container(),
        ),
        if (state.pathPatternSegments.contains('route'))
          BeamPage(
            key: const ValueKey('route'),
            child: Container(),
          ),
        if (state.pathPatternSegments.contains('deeper'))
          BeamPage(
            key: const ValueKey('deeper'),
            child: Container(),
          ),
      ];
}
