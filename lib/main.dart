import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/library_screen.dart';
import 'screens/map_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/stop_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/tour_complete_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

import 'services/analytics_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AnalyticsService.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const CityLoomApp(),
    ),
  );
}

class CityLoomApp extends StatelessWidget {
  const CityLoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityLoom - Greyfriars Kirkyard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppScreenRouter(),
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppScreenRouter(),
        );
      },
      home: const AppScreenRouter(),
    );
  }
}

class AppScreenRouter extends StatelessWidget {
  const AppScreenRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    switch (appState.currentScreen) {
      case AppScreen.home:
        return const HomeScreen();
      case AppScreen.intro:
        return const IntroScreen();
      case AppScreen.mapA:
        return const MapScreen(stopIndex: 1);
      case AppScreen.stopA:
        return const StopScreen(stopIndex: 1);
      case AppScreen.mapB:
        return const MapScreen(stopIndex: 2);
      case AppScreen.stopB:
        return const StopScreen(stopIndex: 2);
      case AppScreen.mapC:
        return const MapScreen(stopIndex: 3);
      case AppScreen.stopC:
        return const StopScreen(stopIndex: 3);
      case AppScreen.complete:
        return const TourCompleteScreen();
      case AppScreen.quizSelect:
      case AppScreen.quizRunner:
      case AppScreen.quizResult:
        return const QuizScreen();
      case AppScreen.library:
        return const LibraryScreen();
      case AppScreen.survey:
        return const SurveyScreen();
    }
  }
}
