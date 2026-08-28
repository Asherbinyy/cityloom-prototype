import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/tour_data.dart';
import '../models/tour_model.dart';
import '../state/app_state.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/map_interactive_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_strip.dart';

class MapScreen extends StatelessWidget {
  final int stopIndex; // 1: Stop A, 2: Stop B, 3: Stop C

  const MapScreen({
    super.key,
    required this.stopIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final TourStop stop = TourData.stops[stopIndex];

    return AppScaffold(
      onBack: () {
        if (stopIndex == 1) {
          appState.navigateTo(AppScreen.intro);
        } else if (stopIndex == 2) {
          appState.navigateTo(AppScreen.stopA);
        } else {
          appState.navigateTo(AppScreen.stopB);
        }
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Dots
          ProgressStrip(currentStep: stop.progressStep),
          const SizedBox(height: 12),

          // Header
          Text(
            stop.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            stop.mapTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            stop.mapDesc,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),

          // Interactive Map Widget with Walking Animation
          MapInteractiveWidget(
            currentStopIndex: stopIndex,
            onStopTap: () => _goToStop(appState),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // "I'm at Stop X" Button
          PrimaryButton(
            text: "I'm at ${stop.label}",
            onPressed: () => _goToStop(appState),
          ),
          const SizedBox(height: 12),

          // Skip Button
          PrimaryButton(
            text: 'Skip this stop',
            isSecondary: true,
            onPressed: () => _skipStop(appState),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _goToStop(AppState appState) {
    if (stopIndex == 1) {
      appState.navigateTo(AppScreen.stopA);
    } else if (stopIndex == 2) {
      appState.navigateTo(AppScreen.stopB);
    } else {
      appState.navigateTo(AppScreen.stopC);
    }
  }

  void _skipStop(AppState appState) {
    if (stopIndex == 1) {
      appState.navigateTo(AppScreen.mapB);
    } else if (stopIndex == 2) {
      appState.navigateTo(AppScreen.mapC);
    } else {
      appState.navigateTo(AppScreen.complete);
    }
  }
}
