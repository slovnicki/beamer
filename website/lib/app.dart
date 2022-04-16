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
            return Scaffold(
              body: Column(
                children: [
                  Header(
                    isDarkTheme: _isDarkTheme,
                    onThemeSwitch: (value) => setState(
                      () => _isDarkTheme = value,
                    ),
                    openNavigationSidebar: () {},
                  ),
                  Expanded(
                    child: constraints.maxWidth < 600
                        ? MobileApp(child: child!)
                        : Row(
                            children: [
                              const NavigationSidebar(),
                              const VerticalDivider(),
                              Expanded(child: child!),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MobileApp extends StatefulWidget {
  const MobileApp({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _MobileAppState createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  bool _animate = false;
  bool _isOpening = false;
  late double _drawerWidth;
  late double _dx;

  Duration get _animationDuration => Duration(milliseconds: _animate ? 200 : 0);

  void _openDrawer() => setState(() {
        _isOpening = false;
        _animate = true;
        _dx = 0;
      });

  void _closeDrawer({bool? animate}) => setState(() {
        _isOpening = false;
        _animate = animate ?? true;
        _dx = -_drawerWidth;
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _drawerWidth = 256;
    _dx = -_drawerWidth;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _isOpening = details.delta.dx > 0;
        _dx += details.delta.dx;
        _dx = _dx.clamp(-_drawerWidth, 0);
        setState(() => _animate = false);
      },
      onHorizontalDragEnd: (details) {
        if (_dx > _drawerWidth / 4 || _isOpening) {
          _openDrawer();
        } else {
          _closeDrawer();
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: _animationDuration,
            transform: Matrix4.translationValues(_drawerWidth + _dx, 0, 0),
            child: GestureDetector(
              onTap: _closeDrawer,
              child: widget.child,
            ),
          ),
          AnimatedContainer(
            duration: _animationDuration,
            transform: Matrix4.translationValues(_dx, 0, 0),
            child: SizedBox(
              width: _drawerWidth,
              child: const NavigationSidebar(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: AnimatedOpacity(
              opacity: -_dx / 256,
              duration: _animationDuration,
              child: const Icon(Icons.swipe_right),
            ),
          ),
        ],
      ),
    );
  }
}
