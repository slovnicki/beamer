import 'package:beamer_website/introduction/widgets/basic_example.dart';
import 'package:beamer_website/shared/code_snippet.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 64.0),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(
                  'https://raw.githubusercontent.com/slovnicki/beamer/master/resources/logo.png',
                ),
                Positioned(
                  top: -32.0,
                  right: -32.0,
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () => launch(
                      'https://docs.flutter.dev/development/packages-and-plugins/favorites',
                    ),
                    child: SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: Image.network(
                        'https://raw.githubusercontent.com/slovnicki/beamer/master/resources/flutter_favorite_badge.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Text(
                  'Welcome to Beamer documentation!',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '(built with Beamer)',
                  style: theme.textTheme.headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: 600,
                  child: Text(
                    '''
Beamer uses the power of Router and implements all the underlying logic for you, letting you explore arbitrarily complex navigation scenarios with ease.

The simplest setup is achieved by using the RoutesLocationBuilder which yields the least amount of code. This is a great choice for applications with fewer navigation scenarios or with shallow page stacks, i.e. when pages are rarely stacked on top of each other.
''',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const CodeSnippet(code: code),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                        ),
                        width: 256.0,
                        height: 420.0,
                        child: BasicExample(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const code = '''
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state, data) => HomeScreen(),
        '/books': (context, state, data) => BooksScreen(),
        '/books/:bookId': (context, state, data) {
          // Take the path parameter of interest from BeamState
          final bookId = state.pathParameters['bookId']!;
          // Collect arbitrary data that persists throughout navigation
          final info = (data as MyObject).info;
          // Use BeamPage to define custom behavior
          return BeamPage(
            key: ValueKey('book-\$bookId'),
            title: 'A Book #\$bookId',
            popToNamed: '/',
            type: BeamPageType.scaleTransition,
            child: BookDetailsScreen(bookId, info),
          );
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
    );
  }
}
''';
