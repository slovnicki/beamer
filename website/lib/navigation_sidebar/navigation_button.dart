import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

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
          onExpansionChanged: (value) {
            if (value) {
              onTap.call();
            }
          },
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
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
  }) : super(key: key);

  final String text;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.hoverColor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
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
