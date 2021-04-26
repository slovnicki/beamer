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
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getTemporaryDirectory(),
  );
  runApp(MyApp(
    authenticationRepository: AuthenticationRepository(),
    userRepository: UserRepository(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    final router = BeamerRouterDelegate(
      guards: [
        BeamGuard(
          guardNonMatching: true,
          pathBlueprints: ['/login'],
          beamToNamed: '/login',
          check: (context, state) =>
              context.select((AuthenticationBloc auth) => auth.isAuthenticated()),
        ),
      ],
      initialPath: '/login',
      locationBuilder: (state) => BeamerLocations(state),
    );
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        ),
        child: BeamerProvider(
          routerDelegate: router,
          child: MaterialApp.router(
            title: 'Authentication with Bloc',
            debugShowCheckedModeBanner: false,
            routeInformationParser: BeamerRouteInformationParser(),
            routerDelegate: router,
            builder: (context, child) {
              return BlocListener<AuthenticationBloc, AuthenticationState>(
                child: child,
                listener: (context, state) {
                  if (state.status == AuthenticationStatus.authenticated)
                    context.beamToNamed('/logged_in_page');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
