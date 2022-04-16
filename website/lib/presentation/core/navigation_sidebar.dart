import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({Key? key}) : super(key: key);

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  late BeamerDelegate _beamer;

  void _setStateListener() => setState(() {});

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
    return SizedBox(
      width: 256,
      child: Column(
        children: [
          NavigationButton(
            text: 'Introduction',
            isSelected: path == '/' || path.contains('books'),
            onTap: () => _beamer.beamToNamed('/'),
            padLeft: false,
          ),
          ExpandableNavigationButton(
            text: 'Quick Start',
            isSelected: path.contains('start'),
            onTap: () => _beamer.beamToNamed('/start'),
            children: [
              NavigationButton(
                text: 'Routes',
                isSelected: path.contains('routes'),
                onTap: () => Beamer.of(context).beamToNamed('/start/routes'),
              ),
              NavigationButton(
                text: 'Beaming',
                isSelected: path.contains('beaming'),
                onTap: () => Beamer.of(context).beamToNamed('/start/beaming'),
              ),
              NavigationButton(
                text: 'Accessing',
                isSelected: path.contains('accessing'),
                onTap: () => Beamer.of(context).beamToNamed('/start/accessing'),
              ),
            ],
          ),
          ExpandableNavigationButton(
            text: 'Key Concepts',
            isSelected: path.contains('concepts'),
            onTap: () => _beamer.beamToNamed('/concepts'),
            children: [
              NavigationButton(
                text: 'BeamLocation',
                isSelected: path.contains('beam-location'),
                onTap: () =>
                    Beamer.of(context).beamToNamed('/concepts/beam-location'),
              ),
              NavigationButton(
                text: 'BeamerDelegate',
                isSelected: path.contains('delegate'),
                onTap: () =>
                    Beamer.of(context).beamToNamed('/concepts/delegate'),
              ),
              NavigationButton(
                text: 'BeamGuard',
                isSelected: path.contains('guard'),
                onTap: () => Beamer.of(context).beamToNamed('/concepts/guard'),
              ),
              NavigationButton(
                text: 'Nested Navigation',
                isSelected: path.contains('nested'),
                onTap: () => Beamer.of(context).beamToNamed('/concepts/nested'),
              ),
            ],
          ),
          ExpandableNavigationButton(
            text: 'Examples',
            isSelected: path.contains('examples'),
            onTap: () => _beamer.beamToNamed('/examples'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _beamer.removeListener(_setStateListener);
    super.dispose();
  }
}

class ExpandableNavigationButton extends StatelessWidget {
  const ExpandableNavigationButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.children = const [],
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final void Function() onTap;
  final List<NavigationButton> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = Beamer.of(context).configuration.location!;
    return Material(
      child: InkWell(
        hoverColor: theme.hoverColor,
        child: ExpansionTile(
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
