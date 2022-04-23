import 'package:flutter/material.dart';

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
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: Icon(
                _isDarkTheme ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                key: ValueKey(_isDarkTheme),
              ),
            ),
            color: Colors.white,
            splashRadius: 24,
            onPressed: () {
              setState(() => _isDarkTheme = !_isDarkTheme);
              widget.onThemeSwitch(_isDarkTheme);
            },
          ),
        ],
      ),
    );
  }
}
