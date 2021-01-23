import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'beam_location.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';

class Beamer extends StatelessWidget {
  Beamer({
    @required this.initialLocation,
    @required this.beamLocations,
    this.app,
  });

  final BeamLocation initialLocation;
  final List<BeamLocation> beamLocations;
  final MaterialApp app;

  static BeamerRouterDelegate of(BuildContext context) {
    return Router.of(context).routerDelegate as BeamerRouterDelegate;
  }

  @override
  Widget build(BuildContext context) {
    return app != null
        ? MaterialApp.router(
            routeInformationParser:
                BeamerRouteInformationParser(beamLocations: beamLocations),
            routerDelegate: BeamerRouterDelegate(
              initialLocation: initialLocation,
              beamLocations: beamLocations,
            ),
            key: app.key,
            scaffoldMessengerKey: app.scaffoldMessengerKey,
            routeInformationProvider: app.routeInformationProvider,
            backButtonDispatcher: app.backButtonDispatcher,
            builder: app.builder,
            title: app.title,
            onGenerateTitle: app.onGenerateTitle,
            color: app.color,
            theme: app.theme,
            darkTheme: app.darkTheme,
            highContrastTheme: app.highContrastTheme,
            highContrastDarkTheme: app.highContrastDarkTheme,
            themeMode: app.themeMode,
            locale: app.locale,
            localizationsDelegates: app.localizationsDelegates,
            localeListResolutionCallback: app.localeListResolutionCallback,
            localeResolutionCallback: app.localeResolutionCallback,
            supportedLocales: app.supportedLocales,
            debugShowMaterialGrid: app.debugShowMaterialGrid,
            showPerformanceOverlay: app.showPerformanceOverlay,
            checkerboardRasterCacheImages: app.checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: app.checkerboardOffscreenLayers,
            showSemanticsDebugger: app.showSemanticsDebugger,
            debugShowCheckedModeBanner: app.debugShowCheckedModeBanner,
            shortcuts: app.shortcuts,
            actions: app.actions,
            restorationScopeId: app.restorationScopeId,
          )
        : Router(
            routeInformationParser:
                BeamerRouteInformationParser(beamLocations: beamLocations),
            routerDelegate: BeamerRouterDelegate(
              initialLocation: initialLocation,
              beamLocations: beamLocations,
            ),
          );
  }
}

extension BeamTo on BuildContext {
  void beamTo(BeamLocation location) {
    (Router.of(this).routerDelegate as BeamerRouterDelegate).beamTo(location);
  }
}

extension BeamBack on BuildContext {
  void beamBack() {
    (Router.of(this).routerDelegate as BeamerRouterDelegate).beamBack();
  }
}
