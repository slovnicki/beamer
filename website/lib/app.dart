import 'package:beamer/beamer.dart';
import 'package:beamer_website/application/routing.dart';
import 'package:beamer_website/presentation/core/header.dart';
import 'package:beamer_website/presentation/core/navigation_sidebar.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _isDarkTheme =
        WidgetsBinding.instance!.window.platformBrightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return BeamerProvider(
      routerDelegate: rootBeamerDelegate,
      child: MaterialApp.router(
        theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        routerDelegate: rootBeamerDelegate,
        routeInformationParser: BeamerParser(),
        builder: (context, child) => LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth < 600
                ? NarrowApp(
                    isDarkTheme: _isDarkTheme,
                    onThemeSwitch: (value) => setState(
                      () => _isDarkTheme = value,
                    ),
                    child: child!,
                  )
                : WideApp(
                    isDarkTheme: _isDarkTheme,
                    onThemeSwitch: (value) => setState(
                      () => _isDarkTheme = value,
                    ),
                    child: child!,
                  );
          },
        ),
      ),
    );
  }
}

class NarrowApp extends StatelessWidget {
  NarrowApp({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeSwitch,
    required this.child,
  }) : super(key: key);

  final bool isDarkTheme;
  final void Function(bool) onThemeSwitch;
  final Widget child;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationSidebar(
        closeDrawer: () => _scaffoldKey.currentState!.openEndDrawer(),
      ),
      body: Column(
        children: [
          Header(
            isDarkTheme: isDarkTheme,
            onThemeSwitch: onThemeSwitch,
            openNavigationSidebar: () =>
                _scaffoldKey.currentState!.openDrawer(),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class WideApp extends StatelessWidget {
  const WideApp({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeSwitch,
    required this.child,
  }) : super(key: key);

  final bool isDarkTheme;
  final void Function(bool) onThemeSwitch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(
            isDarkTheme: isDarkTheme,
            onThemeSwitch: onThemeSwitch,
          ),
          Expanded(
            child: Row(
              children: [
                const NavigationSidebar(),
                const VerticalDivider(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
