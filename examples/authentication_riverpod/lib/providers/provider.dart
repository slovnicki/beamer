import 'package:authentication_riverpod/providers/auth_notifier.dart';
import 'package:authentication_riverpod/services/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) => AppRepository());

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
