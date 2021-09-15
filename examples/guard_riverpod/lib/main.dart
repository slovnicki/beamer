
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guard_riverpod/router.dart';

void main() => runApp(ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // Passing `ref.read`, which is a `Reader` instance, so that we can use
      // riverpod as we see fit.
      routerDelegate: createDelegate(ref.read),
      routeInformationParser: BeamerParser(),
      scaffoldMessengerKey: _scaffoldKey,
    );
  }
}