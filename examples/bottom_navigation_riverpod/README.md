# Bottom Navigation with Riverpod

Includes multiple meamers, global login guard, and persistent navigation
state using Riverpod.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/bottom_navigation_riverpod/example-bottom-navigation-riverpod.gif" alt="example-bottom-navigation-riverpod">
</p>

## Usage

Run `flutter create .` to generate all necessary files, if needed.

## What does this example demonstrate?

* Two independent nested routers, using two Beamers. When you switch between
  two bars back and forth the navigation state in each of them is preserved.
  You can also navigate independently in both of them.
* Global login guard. When BeamerGuard detects that the person is not signed
  in, then it redirects the user to LoginScreen and won't let you use the app
  unless you sing in. The sign in state might be changed at any moment
  through authentication provider.
* Navigation state is preserved between application launches. Both Books and
  Articles screens remember their last location. The app remembers its
  overall last location. Once you restart the app, it restores everything
  just where you left it.

## How example code is structured?

1. `DATA`: Similarly to other examples, these variables hold fake book data.
1. `SCREENS`: 5 simple widgets that represent parts of the app.
1. `LOCATIONS`: Two main beamer locations for this app.
1. `REPOSITORIES`: Classes to manipulate underlying data sources (the idea
   is similar to the **Flutter + Riverpod reference architecture**
   [described by Code with Andrea](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)).
   In this example we store and retrieve data from shared preferences.
1. `CONTROLLERS`: State classes through which Widgets manipulate state and
   receive updates when state changes.
1. `PROVIDERS`: Riverpod based providers for repositories and controllers.
1. `APP`: Stateful Widget with a bottom navigation bar.
1. `main()`: Main function that initializes provider scope and creates
   MaterialApp.

## How does it work?

First of all, bottom navigation bar index in the `AppScreen` stateful widget
is what determines which screen user currently sees: Books or Articles.
The screen themselves are put into an `IndexedStack` within `AppScreen`.

The value of the bottom navigation bar index changes in response to the
current router location change. For example, when we navigate within the
app or if user puts a new URL into a browser. In order to detect each time
the current routing location changes and react correspondigly, we rely on
`didChangeDependencies()` function overload within our stateful `AppScreen`
widget. It works, because `AppScreen` depends on root `BeamerDelegate` in its
`build()` function. So, whenever Beamer updates and notifies its children,
the `didChangeDependencies()` function gets called.

Another place where bottom navigation bar index changes is during `onTap()`
invoked when user taps on one of the bottom navigation bar items. We simply
change the state of the `AppScreen` widget through `setState()` and then
call `BeamerDelegate.update(rebuild: false)` function on the router we
are navigating to, either Books or Articles one in our case.

Root `BeamerDelegate` defines just two routes: `/home/*` and `/login`. This
is done in order to allow global `BeamGuard` check within this root router
delegate to work. It is configured to invoke the check on any route that does
not match the `/login` route. It then reads the authentication state provider
to figure out if the user is signed in. If user is signed out or becomes
signed out, the `BeamGuard` forceflly beams us to the `/login` page.

In order to allow root `BeamerDelegate` to access riverpod provider values
we define it in the scope of `main()` function, where we also initialize
`ProviderContainer`. This is a rather unorthodox method of using Riverpod.
But it allows us to read provider values outside of BuildContext. This is
exactly what we do by reading the value of authentication state provider when
configuring the `BeamGuard`.

To remember the last location of the app, we store 3 values within the
navigation state provider: `booksLocation`, `articlesLocation`, and
`lastLocation`. The first one stores the last known location within the Books
screen. The second one does the same for the Articles screen. And finally,
the last one stores the last known location irrespective of which screen
we are on, books or articles. All three of this values need to be updated
every time we navigate. This is done by defining a `routeListener` function
within the root `BeamerDelegate` that gets called each time app location
changes. And every time it does, new value is stored in the navigation state
provider, which through repository ensures that this information is also
written into the shared settings.

The last piece of the puzzle is to load the last known location, when we
restart the app or sign out and sign in again. The latter is easier to
implement, because we just need to read the last known location from the
provider inside the `onPressed()` function of login button and then beam
to that location. The former, however, proves to be much more problematic.

The issue here is that we have no way of passing the provider value to the
nested children `BeamerDelegate`s. They have to be defined within the
`AppScreenState` class. We cannot define them globally or within the `main()`
function, because then we have conflicting `GlobalKey`s for Navigator state.
We also cannot define them within the `AppScreen` class itself. They have to
be inside the `AppScreenState` in order for everything, including hot-reload,
to work. Unfortunately, the only way to achieve that is to define a state
constuctor, which is a very unrecommended practive. We pass last known
locations to the state as constructor arguments. This way, when application
reloads it continues off the same place we left it. And even better, the
locations of both of the screens are preserved the way we left them.

## Demo sequence

1. Open app → Login screen is shown
1. Try to navigate to /home/books → Stays on Login screen
1. Sign in → Goes to Books screen (default location)

1. Select second book → Opens "Foundation" book
1. Click back button in top left corner → Goes back to Books screen
1. Select third book → Opens "Fahrenheit 451" book

1. Choose Articles tab → Goes to Articles screen
1. Select second article → Opens "Flutter Navigator 2.0..." article

1. Click browser's back button → Goes back to Articles screen
1. Click browser's back button again → Goes back to "Fahrenheit 451" book
1. Click browser's forward button → Goes back to Articles screen
1. Clibk browser's forward button again → Returns to "Flutter Navigator
   2.0..." article

1. Type first book into browser /home/books/1 → Goes to "Stranger in a
   Strange Land" book

1. Switch between two tabs to show state preservation → Both screen keep
   the same state
1. Switch to Articles screen before signing out → Goes to Articles screen

1. Sign out → Login screen is shown
1. Sign in again → Last open screen (Articles) is shown
1. Switch between two tabs to show state preservation → Tabs keep state

1. Reload app completely → App starts with the same state
1. Switch between two tabs to show state preservation → Tabs keep state
