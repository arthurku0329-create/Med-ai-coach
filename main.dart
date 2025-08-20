import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'repo.dart';

/// Entry point for the Med AI Coach application.
///
/// This file sets up the global provider scope and loads
/// persistent data from `SharedPreferences` via [AppRepo].
/// It then launches the MaterialApp with configured routes.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create the repository which will manage local data storage.
  final repo = await AppRepo.create();
  runApp(
    ProviderScope(
      overrides: [repoProvider.overrideWithValue(repo)],
      child: const MedCoachApp(),
    ),
  );
}

/// Top‑level widget for the application.
class MedCoachApp extends StatelessWidget {
  const MedCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Med AI Coach',
      // Use Material3 and a custom color seed for a modern look.
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routerConfig: appRouter,
    );
  }
}