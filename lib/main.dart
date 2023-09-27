import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/data/http/http.dart';
import 'app/data/repositories_implementation/connectivity_repository_impl.dart';
import 'app/data/services/remote/internet_checker.dart';
import 'app/inject_repositories.dart';
import 'app/my_app.dart';
import 'app/presentation/global/controllers/favorites/favorites_controller.dart';
import 'app/presentation/global/controllers/favorites/state/favorites_state.dart';
import 'app/presentation/global/controllers/session_controller.dart';
import 'app/presentation/global/controllers/theme_controller.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  final http = Http(
    client: Client(),
    baseUrl: 'https://api.themoviedb.org/3',
    apiKey: 'Your key',
  );

  final systemDarkMode = ui.window.platformBrightness == Brightness.dark;

  await injectRepositories(
      http: http,
      secureStorage: const FlutterSecureStorage(),
      preferences: await SharedPreferences.getInstance(),
      connectivity: Connectivity(),
      internetChecker: InternetChecker(),
      sytemDarkMode: systemDarkMode);

  final connectivity = ConnectivityRepositoryImpl(
    Connectivity(),
    InternetChecker(),
  );
  await connectivity.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (context) {
            final preferencesRepository = Repositories.preferences;
            return ThemeController(
              preferencesRepository.darkMode,
              preferencesRepository: preferencesRepository,
            );
          },
        ),
        ChangeNotifierProvider<SessionController>(
          create: (context) => SessionController(
            authenticationRepository: Repositories.authentication,
          ),
        ),
        ChangeNotifierProvider<FavoritesController>(
          create: (context) => FavoritesController(
            FavoritesState.loading(),
            accountRepository: Repositories.account,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
