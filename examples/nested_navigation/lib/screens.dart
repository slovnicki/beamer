import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'locations.dart';

class MenuButton extends StatefulWidget {
  MenuButton({
    required this.beamer,
    required this.uri,
    required this.child,
  });

  final GlobalKey<BeamerState> beamer;
  final String uri;
  final Widget child;

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  void _setStateListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => widget
        .beamer.currentState?.routerDelegate
        .addListener(_setStateListener));
  }

  @override
  Widget build(BuildContext context) {
    final path = context.currentBeamLocation.state.uri.path;

    return ElevatedButton(
      onPressed: () =>
          widget.beamer.currentState?.routerDelegate.beamToNamed(widget.uri),
      style: ButtonStyle(
        backgroundColor: path.contains(widget.uri)
            ? MaterialStateProperty.all<Color>(Colors.green)
            : MaterialStateProperty.all<Color>(Colors.blue),
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.beamer.currentState?.routerDelegate
        .removeListener(_setStateListener);
    super.dispose();
  }
}

class HomeScreen extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/books',
                  child: Text('Books'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/articles',
                  child: Text('Articles'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          if (context.currentBeamLocation.state.uri.path.isEmpty)
            Expanded(
              child: Container(
                child: Center(
                  child: Text('Home'),
                ),
              ),
            )
          else
            Expanded(
              child: Beamer(
                key: _beamerKey,
                routerDelegate: BeamerDelegate(
                  locationBuilder: (state) =>
                      state.uri.pathSegments.contains('articles')
                          ? ArticlesLocation(state)
                          : BooksLocation(state),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/books/authors',
                  child: Text('Book Authors'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/books/genres',
                  child: Text('Book Genres'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          Expanded(
            child: Beamer(
              key: _beamerKey,
              routerDelegate: BeamerDelegate(
                locationBuilder: (state) => BooksContentLocation(state),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BooksHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books Home'),
      ),
    );
  }
}

class BookAuthorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Authors'),
      ),
    );
  }
}

class BookGenresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Genres'),
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/articles/authors',
                  child: Text('Article Authors'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  beamer: _beamerKey,
                  uri: '/articles/genres',
                  child: Text('Article Genres'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          Expanded(
            child: Beamer(
              key: _beamerKey,
              routerDelegate: BeamerDelegate(
                locationBuilder: (state) => ArticlesContentLocation(state),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticlesHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles Home'),
      ),
    );
  }
}

class ArticleAuthorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Authors'),
      ),
    );
  }
}

class ArticleGenresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Genres'),
      ),
    );
  }
}
