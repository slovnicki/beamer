import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ],
      ),
    );
  }
}
