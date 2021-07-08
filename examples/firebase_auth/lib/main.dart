import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: "test@beamer.dev",
                password: "testing",
              );
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
              }
            }
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}

class LoggedInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logged In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async => await FirebaseAuth.instance.signOut(),
          child: Text('Log out'),
        ),
      ),
    );
  }
}

// APP
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _routerDelegate;

  Future<FirebaseApp> _initialization = Firebase.initializeApp();
  User? _user;

  @override
  void initState() {
    super.initState();
    _routerDelegate = BeamerDelegate(
      initialPath: _user != null ? '/loggedin' : '/login',
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/login': (context, state) => LoginScreen(),
          '/loggedin': (context, state) => LoggedInScreen(),
        },
      ),
      guards: [
        BeamGuard(
          pathBlueprints: ['/login'],
          guardNonMatching: true,
          check: (context, location) => _user != null,
          beamToNamed: '/login',
        ),
        BeamGuard(
          pathBlueprints: ['/login'],
          check: (context, location) => _user == null,
          beamToNamed: '/loggedin',
        ),
      ],
    );
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() => _user = user);
      } else {
        print('User is signed in!');
        setState(() => _user = user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BeamerProvider(
      routerDelegate: _routerDelegate,
      child: MaterialApp.router(
        routerDelegate: _routerDelegate,
        routeInformationParser: BeamerParser(),
        builder: (context, child) {
          return FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(color: Colors.red);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                // this child is the Navigator stack produced by Beamer
                return child!;
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() => runApp(MyApp());
