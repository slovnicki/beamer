import 'package:beamer/beamer.dart';
import 'package:beamer_website/introduction/introduction_screen.dart';
import 'package:beamer_website/navigation_sidebar/navigation_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isDarkTheme = false;

  final rootBeamerDelegate = BeamerDelegate(
    initialPath: '/',
    transitionDelegate: const NoAnimationTransitionDelegate(),
    locationBuilder: RoutesLocationBuilder(
      routes: {
        RegExp(r'^(?!(/start.*|/concepts.*|/examples.*)$).*$'):
            (_, state, ___) => BeamPage(
                  key: ValueKey(state.uri),
                  title: 'Introduction',
                  child: const IntroductionScreen(),
                ),
        '/start': (_, __, ___) => WIPScreen(),
        '/start/*': (_, __, ___) => WIPScreen(),
        '/concepts': (_, __, ___) => WIPScreen(),
        '/concepts/*': (_, __, ___) => WIPScreen(),
        '/examples': (_, __, ___) => WIPScreen(),
      },
    ),
  );

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

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeSwitch,
    required this.openNavigationSidebar,
  }) : super(key: key);

  final bool isDarkTheme;
  final void Function(bool) onThemeSwitch;
  final void Function() openNavigationSidebar;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: kToolbarHeight,
      width: double.infinity,
      color: theme.primaryColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.network(
              'https://raw.githubusercontent.com/slovnicki/beamer/master/resources/logo.png',
            ),
          ),
          Text(
            'Beamer',
            style: theme.textTheme.headline6!.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Text(
            'Dark theme',
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Switch(
            value: _isDarkTheme,
            onChanged: (value) {
              setState(() => _isDarkTheme = value);
              widget.onThemeSwitch(value);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: VerticalDivider(),
          ),
          Text(
            'pub.dev',
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 4.0),
          InkWell(
            onTap: () => launch('https://pub.dev/packages/beamer'),
            child: const Icon(Icons.launch, color: Colors.white),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

class WIPScreen extends StatelessWidget {
  const WIPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Coming soon...',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
