import 'package:authentication_bloc/beamer_locations.dart';
import 'package:authentication_bloc/bloc/authentication_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  runApp(
    MyApp(
      authenticationRepository: AuthenticationRepository(),
      userRepository: UserRepository(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  final routerDelegate = BeamerRouterDelegate(
    guards: [
      // Redirect to /login if the user is not authenticated:
      BeamGuard(
        guardNonMatching: true,
        pathBlueprints: ['/'],
        beamToNamed: '/login',
        check: (context, state) =>
            context.select((AuthenticationBloc auth) => auth.isAuthenticated()),
      ),
      // Redirect to /logged_in_page if the user is authenticated:
      BeamGuard(
        guardNonMatching: true,
        pathBlueprints: ['/login'],
        beamToNamed: '/logged_in_page',
        check: (context, state) => context
            .select((AuthenticationBloc auth) => !auth.isAuthenticated()),
      ),
    ],
    initialPath: '/login',
    locationBuilder: (state) => BeamerLocations(state),
  );

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        ),
        child: BeamerProvider(
          routerDelegate: routerDelegate,
          child: MaterialApp.router(
            title: 'Authentication with Bloc',
            debugShowCheckedModeBanner: false,
            routeInformationParser: BeamerRouteInformationParser(),
            routerDelegate: routerDelegate,
            builder: (context, child) {
              return BlocListener<AuthenticationBloc, AuthenticationState>(
                child: child,
                listener: (context, state) {
                  if (state.status == AuthenticationStatus.authenticated) {
                    context.beamToNamed('/logged_in_page',
                        replaceCurrent: true);
                  } else {
                    context.beamToNamed('/login', replaceCurrent: true);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
