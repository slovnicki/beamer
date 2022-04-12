import 'package:beamer/beamer.dart';
import 'package:beamer_website/introduction/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(App());

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
        RegExp(r'^(?!(/quick-start|/beam-locations)$).*$'): (_, state, ___) =>
            BeamPage(
              key: ValueKey(state.uri),
              title: 'Introduction',
              child: const IntroductionScreen(),
            ),
        '/quick-start': (_, __, ___) => WIPScreen(),
        '/beam-locations': (_, __, ___) => WIPScreen(),
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
        builder: (context, child) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              body: constraints.maxWidth < 600
                  ? Column(
                      children: [
                        _body(child!),
                        const NavigationBar.row(),
                      ],
                    )
                  : Row(
                      children: [
                        const NavigationBar.column(),
                        _body(child!),
                      ],
                    ),
            );
          });
        },
      ),
    );
  }

  Widget _body(Widget child) => Expanded(
        child: Column(
          children: [
            Header(
              isDarkTheme: _isDarkTheme,
              onThemeSwitch: (value) => setState(
                () => _isDarkTheme = value,
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeSwitch,
  }) : super(key: key);

  final bool isDarkTheme;
  final void Function(bool) onThemeSwitch;

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
    return Container(
      height: kToolbarHeight,
      width: double.infinity,
      color: Colors.blue,
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          Text(
            'Check Beamer on pub.dev',
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 8.0),
          InkWell(
            onTap: () => launch('https://pub.dev/packages/beamer'),
            child: const Icon(Icons.launch, color: Colors.white),
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
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

enum NavigationBarType { row, column }

class NavigationBar extends StatefulWidget {
  const NavigationBar({
    Key? key,
    this.type = NavigationBarType.column,
  }) : super(key: key);

  const NavigationBar.row({Key? key})
      : type = NavigationBarType.row,
        super(key: key);

  const NavigationBar.column({Key? key})
      : type = NavigationBarType.column,
        super(key: key);

  final NavigationBarType type;

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  late BeamerDelegate _beamer;

  void _setStateListener() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _beamer = Beamer.of(context);
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => _beamer.addListener(_setStateListener),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _beamer.configuration.location!;
    return Container(
      color: Colors.blue[300],
      child: widget.type == NavigationBarType.row
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buttons(path),
            )
          : SizedBox(
              width: 192,
              child: Column(
                children:
                    <Widget>[_title(Theme.of(context))] + _buttons(path, 0),
              ),
            ),
    );
  }

  Widget _title(ThemeData theme) => Container(
        height: kToolbarHeight,
        color: Colors.blue[900],
        child: Center(
          child: Text(
            'Content',
            style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
        ),
      );

  List<Widget> _buttons(String path, [int flex = 1]) => [
        const Divider(),
        Expanded(
          flex: flex,
          child: NavigationButton(
            text: 'Introduction',
            isSelected: path == '/' || path.contains('books'),
            onTap: () => _beamer.beamToNamed('/'),
          ),
        ),
        const Divider(),
        Expanded(
          flex: flex,
          child: NavigationButton(
            text: 'Quick Start',
            isSelected: path.contains('quick-start'),
            onTap: () => _beamer.beamToNamed('/quick-start'),
          ),
        ),
        const Divider(),
        Expanded(
          flex: flex,
          child: NavigationButton(
            text: 'Beam Locations',
            isSelected: path.contains('beam-locations'),
            onTap: () => _beamer.beamToNamed('/beam-locations'),
          ),
        ),
        const Divider(),
      ];

  @override
  void dispose() {
    _beamer.removeListener(_setStateListener);
    super.dispose();
  }
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        color: isSelected ? Colors.blue : Colors.transparent,
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.button!.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class WIPScreen extends StatelessWidget {
  const WIPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Coming soon...',
            style: TextStyle(fontSize: 28),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
