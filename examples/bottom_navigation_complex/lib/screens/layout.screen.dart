import 'package:bottom_navigation_complex/routers/books.router.dart';
import 'package:bottom_navigation_complex/routers/articles.router.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  final List<String> routes = ['/Books', '/Articles'];
  final List<BeamerDelegate> routerDelegates = [booksRouterDelegate, articlesRouterDelegate];
  late List<Widget> children = List.generate(routes.length, (_) => const SizedBox.shrink());
  late int currentIndex;

  @override
  void didChangeDependencies() {
    final uriString = Beamer.of(context).configuration.location!;
    int index = routes.indexWhere((route) => uriString.startsWith(route));
    _updateCurrentIndex(index != -1 ? index : 0);
    super.didChangeDependencies();
  }

  void _updateCurrentIndex(int index) {
    if (children[index] is SizedBox) {
      children[index] = Beamer(
        backButtonDispatcher: BeamerBackButtonDispatcher(delegate: Beamer.of(context).root, alwaysBeamBack: true),
        routerDelegate: routerDelegates[index],
      );
    }
    (children[index] as Beamer).routerDelegate.update(rebuild: false);
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.beamToNamed('/Settings'),
          )
        ],
      ),
      body: IndexedStack(index: currentIndex, children: children),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
          BottomNavigationBarItem(label: 'Articles', icon: Icon(Icons.article)),
        ],
        currentIndex: currentIndex,
        onTap: _updateCurrentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
