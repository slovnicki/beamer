import 'package:flutter/material.dart';

import 'package:beamer/beamer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
  },
];

const List<Map<String, String>> articles = [
  {
    'id': '1',
    'title': 'Explaining Flutter Nav 2.0 and Beamer',
    'author': 'Toby Lewis',
  },
  {
    'id': '2',
    'title': 'Flutter Navigator 2.0 for mobile dev: 101',
    'author': 'Lulupointu',
  },
  {
    'id': '3',
    'title': 'Flutter: An Easy and Pragmatic Approach to Navigator 2.0',
    'author': 'Marco Muccinelli',
  },
];

// SCREENS
class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugLog("BooksScreen | build() | invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']!),
                subtitle: Text(book['author']!),
                onTap: () {
                  final destination = '/home/books/${book['id']}';
                  debugLog("BooksScreen | going to beam to $destination");
                  context.beamToNamed(destination);
                  debugLog("BooksScreen | just beamed to: $destination");
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({required this.book});
  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    debugLog("BookDetailsScreen | build() | invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${book['author']}'),
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugLog("ArticlesScreen | build() | invoked");
    return Scaffold(
      appBar: AppBar(title: Text('Articles')),
      body: ListView(
        children: articles
            .map(
              (article) => ListTile(
                title: Text(article['title']!),
                subtitle: Text(article['author']!),
                onTap: () {
                  final destination = '/home/articles/${article['id']}';
                  debugLog("ArticlesScreen | going to beam to $destination");
                  context.beamToNamed(destination);
                  debugLog("ArticlesScreen | just beamed to: $destination");
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({required this.article});
  final Map<String, String> article;

  @override
  Widget build(BuildContext context) {
    // debugLog("ArticleDetailsScreen.build invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${article['author']}'),
      ),
    );
  }
}

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugLog("LoginScreen | build() | invoked");

    final signedIn = ref.read(authStateControllerProvider);
    debugLog("LoginScreen | build() | "
        "signedIn provider state before returning a Scaffold: $signedIn");

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final signedInBefore = ref.read(authStateControllerProvider);
            debugLog("LoginScreen | ElevatedButton | onPressed() | "
                "signedIn state before controller toggle: $signedInBefore");
            ref.read(authStateControllerProvider.notifier).toggleSignIn();
            final signedInAfter = ref.read(authStateControllerProvider);
            debugLog("LoginScreen | ElevatedButton | onPressed() | "
                "signedIn state after controller toggle: ${signedInAfter}");

            final lastLocation =
                ref.read(navigationStateControllerProvider).lastLocation;
            debugLog("LoginScreen | ElevatedButton | onPressed() | "
                "going to beam to destination: $lastLocation");
            context.beamToNamed(lastLocation);
            debugLog("LoginScreen | ElevatedButton | onPressed() | "
                "just beamed to destination: $lastLocation");
          },
          child: signedIn ? const Text('Sign out') : const Text('Sign in'),
        ),
      ),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/home/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("BooksLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('books'),
        title: 'Books',
        type: BeamPageType.noTransition,
        child: BooksScreen(),
      ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          title: books.firstWhere(
              (book) => book['id'] == state.pathParameters['bookId'])['title'],
          child: BookDetailsScreen(
            book: books.firstWhere(
                (book) => book['id'] == state.pathParameters['bookId']),
          ),
        ),
    ];

    debugLog("BooksLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}

class ArticlesLocation extends BeamLocation<BeamState> {
  ArticlesLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/home/articles/:articleId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("ArticlesLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('articles'),
        title: 'Articles',
        type: BeamPageType.noTransition,
        child: ArticlesScreen(),
      ),
      if (state.pathParameters.containsKey('articleId'))
        BeamPage(
          key: ValueKey('articles-${state.pathParameters['articleId']}'),
          title: articles.firstWhere((article) =>
              article['id'] == state.pathParameters['articleId'])['title'],
          child: ArticleDetailsScreen(
            article: articles.firstWhere((article) =>
                article['id'] == state.pathParameters['articleId']),
          ),
        ),
    ];

    debugLog("ArticlesLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}

// REPOSITORIES
class AuthRepository {
  const AuthRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  bool get signedIn {
    final result = sharedPreferences.getBool('signedIn') ?? false;
    debugLog("AuthRepository | get signedIn | "
        "signedIn state to be returned: $result");
    return result;
  }

  set signedIn(bool state) {
    sharedPreferences.setBool('signedIn', state);
    debugLog("AuthRepository | set signedIn | "
        "new signedIn state was just set: $state");
  }
}

class NavigationStateRepository {
  const NavigationStateRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  String get booksLocation {
    final result =
        sharedPreferences.getString('booksLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get booksLocation | "
        "location to be returned: $result");
    return result;
  }

  set booksLocation(String location) {
    sharedPreferences.setString('booksLocation', location);
    debugLog("NavigationStateRepository | set booksLocation | "
        "new location was just set: $location");
  }

  String get articlesLocation {
    final result =
        sharedPreferences.getString('articlesLocation') ?? '/home/articles';
    debugLog("NavigationStateRepository | get articlesLocation | "
        "location to be returned: $result");
    return result;
  }

  set articlesLocation(String location) {
    sharedPreferences.setString('articlesLocation', location);
    debugLog("NavigationStateRepository | set articlesLocation | "
        "new location was just set: $location");
  }

  String get lastLocation {
    final result = sharedPreferences.getString('lastLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get lastLocation | "
        "location to be returned: $result");
    return result;
  }

  set lastLocation(String location) {
    sharedPreferences.setString('lastLocation', location);
    debugLog("NavigationStateRepository | set lastLocation | "
        "new location was just set: $location");
  }
}

// CONTROLLERS
class AuthStateController extends Notifier<bool> {
  @override
  bool build() {
    final signedIn = ref.watch(authRepositoryProvider).signedIn;
    debugLog("AuthStateController | build() | "
        "signedIn state to be returned: $signedIn");
    return signedIn;
  }

  void toggleSignIn() {
    debugLog("AuthStateController | toggleSignIn() | "
        "signedIn state before toggle: $state");
    state = !state;
    ref.read(authRepositoryProvider).signedIn = state;
    debugLog("AuthStateController | toggleSignIn() | "
        "signedIn state after toggle: $state");
  }
}

class NavigationState {
  const NavigationState(
      this.booksLocation, this.articlesLocation, this.lastLocation);
  final String booksLocation;
  final String articlesLocation;
  final String lastLocation;

  String toString() {
    return "NavigationState("
        "booksLocation: $booksLocation, "
        "articlesLocation: $articlesLocation, "
        "lastLocation: $lastLocation)";
  }
}

class NavigationStateController extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    final provider = ref.watch(navigationStateRepositoryProvider);
    final result = NavigationState(provider.booksLocation,
        provider.articlesLocation, provider.lastLocation);
    debugLog("NavigationStateController | build() | "
        "about to return ${result.toString()}");
    return result;
  }

  void setBooksLocation(String location) {
    debugLog("NavigationStateController | setBooksLocation() | "
        "state.booksLocation before: ${state.booksLocation}");
    state =
        NavigationState(location, state.articlesLocation, state.lastLocation);
    ref.read(navigationStateRepositoryProvider).booksLocation = location;
    debugLog("NavigationStateController | setBooksLocation() | "
        "state.booksLocation after: ${state.booksLocation}");
  }

  void setArticlesLocation(String location) {
    debugLog("NavigationStateController | setArticlesLocation() | "
        "state.articlesLocation before: ${state.articlesLocation}");
    state = NavigationState(state.booksLocation, location, state.lastLocation);
    ref.read(navigationStateRepositoryProvider).articlesLocation = location;
    debugLog("NavigationStateController | setArticlesLocation() | "
        "state.articlesLocation after: ${state.articlesLocation}");
  }

  void setLastLocation(String location) {
    debugLog("NavigationStateController | setLastLocation() | "
        "state.articlesLocation before: ${state.lastLocation}");
    state =
        NavigationState(state.booksLocation, state.articlesLocation, location);
    ref.read(navigationStateRepositoryProvider).lastLocation = location;
    debugLog("NavigationStateController | setLastLocation() | "
        "state.articlesLocation after: ${state.lastLocation}");
  }
}

// PROVIDERS
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthRepository(sharedPreferences);
});

final authStateControllerProvider =
    NotifierProvider<AuthStateController, bool>(AuthStateController.new);

final navigationStateRepositoryProvider =
    Provider<NavigationStateRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return NavigationStateRepository(sharedPreferences);
});

final navigationStateControllerProvider =
    NotifierProvider<NavigationStateController, NavigationState>(
        NavigationStateController.new);

// APP
class AppScreen extends ConsumerStatefulWidget {
  AppScreen(this.booksLocation, this.articlesLocation, this.lastLocation);
  final String booksLocation;
  final String articlesLocation;
  final String lastLocation;
  @override
  AppScreenState createState() =>
      AppScreenState(booksLocation, articlesLocation, lastLocation);
}

class AppScreenState extends ConsumerState<AppScreen> {
  AppScreenState(
      String booksLocation, String articlesLocation, String lastLocation)
      : routerDelegates = [
          BeamerDelegate(
            initialPath: booksLocation,
            locationBuilder: (routeInformation, _) {
              debugLog("AppScreenState | routerDelegates[0] (books) | "
                  "locationBuilder() | "
                  "incoming routeInformation: ${routeInformation.location}");
              BeamLocation result = NotFound(path: routeInformation.location!);
              if (routeInformation.location!.contains('books')) {
                result = BooksLocation(routeInformation);
              }
              debugLog("AppScreenState | routerDelegates[0] (books) | "
                  "locationBuilder() | going to return: $result");
              return result;
            },
          ),
          BeamerDelegate(
            initialPath: articlesLocation,
            locationBuilder: (routeInformation, _) {
              debugLog("AppScreenState | routerDelegates[1] (articles) | "
                  "locationBuilder() | "
                  "incoming routeInformation: ${routeInformation.location}");
              BeamLocation result = NotFound(path: routeInformation.location!);
              if (routeInformation.location!.contains('articles')) {
                result = ArticlesLocation(routeInformation);
              }
              debugLog("AppScreenState | routerDelegates[1] (articles) | "
                  "locationBuilder() | going to return: $result");
              return result;
            },
          ),
        ];

  late int bottomNavBarIndex;

  final List<BeamerDelegate> routerDelegates;

  // This method will be called every time the
  // Beamer.of(context) changes.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final location = Beamer.of(context).configuration.location!;
    debugLog("AppScreenState | didChangeDependencies() | "
        "uriString read from Beamer.of(context): $location");
    bottomNavBarIndex = location.contains('books') ? 0 : 1;
    debugLog("AppScreenState | didChangeDependencies() | "
        "computed bottomNavBarIndex: $bottomNavBarIndex");
  }

  @override
  Widget build(BuildContext context) {
    debugLog("AppScreenState | build() | invoked");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
        actions: [
          IconButton(
            onPressed: () {
              final controller = ref.read(authStateControllerProvider.notifier);
              controller.toggleSignIn();
              Beamer.of(context).update();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: bottomNavBarIndex,
        children: [
          Beamer(routerDelegate: routerDelegates[0]),
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(32.0),
            child: Beamer(routerDelegate: routerDelegates[1]),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomNavBarIndex,
        items: [
          BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
          BottomNavigationBarItem(label: 'Articles', icon: Icon(Icons.article)),
        ],
        onTap: (index) {
          debugLog("AppScreenState | BottomNavigationBar | onTap() | "
              "new incoming index value: $index "
              "(old value: $bottomNavBarIndex)");
          if (index != bottomNavBarIndex) {
            debugLog("AppScreenState | BottomNavigationBar | onTap() | "
                "index != bottomNavBarIndex");
            setState(() {
              bottomNavBarIndex = index;
            });
            routerDelegates[bottomNavBarIndex].update(rebuild: false);
          }
        },
      ),
    );
  }
}

void main() async {
  debugLog("main() | Main function started");

  WidgetsFlutterBinding.ensureInitialized();
  debugLog("main() | WidgetsFlutterBinding.ensureInitialized executed");

  Beamer.setPathUrlStrategy();
  debugLog("main() | Beamer.setPathUrlStrategy executed");

  final sharedPreferences = await SharedPreferences.getInstance();
  debugLog("main() | sharedPreferences instance obtained");

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final booksInitialPath =
      container.read(navigationStateControllerProvider).booksLocation;
  final articlesInitialPath =
      container.read(navigationStateControllerProvider).articlesLocation;
  final lastInitialPath =
      container.read(navigationStateControllerProvider).lastLocation;

  final routerDelegate = BeamerDelegate(
    initialPath: lastInitialPath,
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/home/*': (context, state, data) =>
            AppScreen(booksInitialPath, articlesInitialPath, lastInitialPath),
        '/login': (context, state, data) => BeamPage(
          key: ValueKey('login'),
          title: 'Login',
          child: LoginScreen(),
        ),
      },
    ),
    buildListener: (context, delegate) {
      final location = Beamer.of(context).configuration.location;
      debugLog("routerDelegate | buildListener() | "
          "location: $location");
    },
    routeListener: (routeInformation, delegate) {
      final location = routeInformation.location;

      Future(() {
        if (location != null) {
          debugLog("routerDelegate | routeListener() | "
              "about to save location: $location");

          if (location.startsWith('/home/books') ||
              location.startsWith('/home/articles')) {
            container
                .read(navigationStateControllerProvider.notifier)
                .setLastLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved last location: $location");
          }

          if (location.startsWith('/home/books')) {
            container
                .read(navigationStateControllerProvider.notifier)
                .setBooksLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved books location: $location");
          } else if (location.startsWith('/home/articles')) {
            container
                .read(navigationStateControllerProvider.notifier)
                .setArticlesLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved articles location: $location");
          }
        }
      });
    },
    guards: [
      BeamGuard(
        pathPatterns: ['/login'],
        guardNonMatching: true,
        check: (context, state) {
          debugLog("routerDelegate | "
              "BeamGuard | check() | is about to retrieve signedIn state");
          final signedIn = container.read(authStateControllerProvider);
          debugLog("routerDelegate | "
              "BeamGuard | check() | obtained signedIn state: $signedIn");
          return signedIn;
        },
        beamToNamed: (origin, target, deepLink) => '/login',
      ),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(
          delegate: routerDelegate,
        ),
      ),
    ),
  );
}

void debugLog(String value) {
  final now = DateTime.now();
  print("[$now] $value");
}
