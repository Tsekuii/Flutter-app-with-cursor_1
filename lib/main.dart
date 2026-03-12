import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/lobby_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'presentation/blocs/app_nav/app_nav_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/lesson/lesson_bloc.dart';
import 'presentation/blocs/lobby/lobby_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/quiz_create/quiz_create_bloc.dart';
import 'presentation/blocs/settings/settings_cubit.dart';
import 'presentation/pages/auth_page.dart';
import 'presentation/pages/main_shell.dart';

void main() {
  runApp(const OlimpiadApp());
}

class OlimpiadApp extends StatelessWidget {
  const OlimpiadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => LessonRepository()),
        RepositoryProvider(create: (_) => QuizRepository()),
        RepositoryProvider(create: (_) => LobbyRepository()),
        RepositoryProvider(create: (c) => ProfileRepository(c.read<AuthRepository>())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => AuthBloc(c.read<AuthRepository>())..add(AuthCheckRequested())),
          BlocProvider(create: (_) => AppNavBloc()),
          BlocProvider(create: (c) => LessonBloc(c.read<LessonRepository>())),
          BlocProvider(create: (c) => QuizCreateBloc(c.read<QuizRepository>())),
          BlocProvider(create: (c) => LobbyBloc(c.read<LobbyRepository>())),
          BlocProvider(create: (c) => ProfileBloc(c.read<ProfileRepository>())),
          BlocProvider(create: (_) => SettingsCubit()),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (a, b) => a.themeMode != b.themeMode,
          builder: (context, settings) {
            final theme = settings.themeMode == ThemeMode.dark ? AppTheme.dark() : AppTheme.light();
            return MaterialApp(
              title: 'Олимпиад',
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (a, b) => a.status != b.status,
                builder: (context, authState) {
                  if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (authState.status == AuthStatus.authenticated) {
                    return const MainShell();
                  }
                  return const AuthPage();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
