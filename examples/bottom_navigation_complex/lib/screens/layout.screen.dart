import 'package:bottom_navigation_complex/routers/books.router.dart';
import 'package:bottom_navigation_complex/routers/articles.router.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
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
  late List<Beamer> children = List.generate(
      routes.length,
      (index) => Beamer(
            backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegates[index], alwaysBeamBack: true),
            routerDelegate: routerDelegates[index],
          ));
  late int currentIndex = -1;

  @override
  void didChangeDependencies() {
    final uriString = Beamer.of(context).configuration.location!;
    int index = routes.indexWhere((route) => uriString.startsWith(route));
    _updateCurrentIndex(index != -1 ? index : 0);
    super.didChangeDependencies();
  }

  void _updateCurrentIndex(int index) {
    // if the index is not the same, then we need to update the route
    if (currentIndex != index) {
      // Fix: After build complete of the new screen (lazy), update the route to trigger the history
      if (currentIndex != -1) WidgetsBinding.instance.addPostFrameCallback((_) => children[index].routerDelegate.update(rebuild: false));
      setState(() => currentIndex = index);
    } else {
      // If the index is the same, reset the Beamer to the initial state.
      children[index].routerDelegate.beamToReplacementNamed(routes[index]);
    }
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
      body: LazyLoadIndexedStack(index: currentIndex, children: children),
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
