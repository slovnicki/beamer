import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({Key? key, this.closeDrawer}) : super(key: key);

  final void Function()? closeDrawer;

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  late bool _isDrawer;
  late BeamerDelegate _beamer;

  void _setStateListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    _isDrawer = widget.closeDrawer != null;
    Future.delayed(Duration.zero, () => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _beamer = Beamer.of(context);
    _beamer.removeListener(_setStateListener);
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => _beamer.addListener(_setStateListener),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _beamer.configuration.location!;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: _isDrawer ? kToolbarHeight : 0.0),
      child: SizedBox(
        width: 256,
        child: MaybeDrawer(
          isDrawer: _isDrawer,
          child: ListView(
            children: [
              NavigationButton(
                text: 'Introduction',
                isSelected: path == '/' || path.contains('books'),
                onTap: () {
                  _beamer.beamToNamed('/');
                  widget.closeDrawer?.call();
                },
                padLeft: false,
              ),
              ExpandableNavigationButton(
                text: 'Quick Start',
                isSelected: path.contains('start'),
                children: [
                  NavigationButton(
                    text: 'Routes',
                    isSelected: path.contains('routes'),
                    onTap: () {
                      Beamer.of(context).beamToNamed('/start/routes');
                      widget.closeDrawer?.call();
                    },
                  ),
                  NavigationButton(
                    text: 'Beaming',
                    isSelected: path.contains('beaming'),
                    onTap: () {
                      Beamer.of(context).beamToNamed('/start/beaming');
                      widget.closeDrawer?.call();
                    },
                  ),
                  NavigationButton(
                    text: 'Accessing',
                    isSelected: path.contains('accessing'),
                    onTap: () {
                      Beamer.of(context).beamToNamed('/start/accessing');
                      widget.closeDrawer?.call();
                    },
                  ),
                ],
              ),
              ExpandableNavigationButton(
                text: 'Key Concepts',
                isSelected: path.contains('concepts'),
                children: [
                  NavigationButton(
                    text: 'Beam Locations',
                    isSelected: path.contains('beam-locations'),
                    onTap: () {
                      Beamer.of(context)
                          .beamToNamed('/concepts/beam-locations');
                      widget.closeDrawer?.call();
                    },
                  ),
                  NavigationButton(
                    text: 'Guards',
                    isSelected: path.contains('guards'),
                    onTap: () {
                      Beamer.of(context).beamToNamed('/concepts/guards');
                      widget.closeDrawer?.call();
                    },
                  ),
                  NavigationButton(
                    text: 'Nested Navigation',
                    isSelected: path.contains('nested'),
                    onTap: () {
                      Beamer.of(context)
                          .beamToNamed('/concepts/nested-navigation');
                      widget.closeDrawer?.call();
                    },
                  ),
                ],
              ),
              ExpandableNavigationButton(
                text: 'Examples',
                isSelected: path.contains('examples'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _beamer.removeListener(_setStateListener);
    super.dispose();
  }
}

class MaybeDrawer extends StatelessWidget {
  const MaybeDrawer({
    Key? key,
    this.isDrawer = false,
    required this.child,
  }) : super(key: key);

  final bool isDrawer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return isDrawer ? Drawer(child: child) : child;
  }
}

class ExpandableNavigationButton extends StatelessWidget {
  const ExpandableNavigationButton({
    Key? key,
    required this.text,
    required this.isSelected,
    this.children = const [],
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final List<NavigationButton> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: InkWell(
        hoverColor: theme.hoverColor,
        child: ExpansionTile(
          key: ValueKey('$isSelected'),
          initiallyExpanded: isSelected,
          tilePadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.button!.copyWith(
                    color: isSelected ? Colors.blue : null,
                  ),
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.padLeft = true,
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final void Function() onTap;
  final bool padLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.hoverColor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0) +
              EdgeInsets.only(left: padLeft ? 16.0 : 0.0),
          child: Text(
            text,
            style: Theme.of(context).textTheme.button!.copyWith(
                  color: isSelected ? Colors.blue : null,
                ),
          ),
        ),
      ),
    );
  }
}
