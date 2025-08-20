import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/tasks_page.dart';
import 'pages/review_page.dart';
import 'pages/wellness_log_page.dart';
import 'pages/dashboard_page.dart';

/// Configure all application routes using GoRouter.
///
/// The application consists of four primary pages:
///  - `/tasks`: display today’s study plan and countdown.
///  - `/review`: review flashcards using the SM‑2 algorithm.
///  - `/wellness`: record sleep, exercise, mood and stress.
///  - `/dashboard`: visualise progress and wellness trends.
final appRouter = GoRouter(
  initialLocation: '/tasks',
  routes: [
    GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
    GoRoute(path: '/review', builder: (_, __) => const ReviewPage()),
    GoRoute(path: '/wellness', builder: (_, __) => const WellnessLogPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
  ],
);

/// A helper widget that wraps child pages and provides a bottom
/// navigation bar for quick switching between pages.
class HomeScaffold extends StatelessWidget {
  final Widget child;
  const HomeScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Define the navigation bar entries.
    final tabs = [
      ('今日任務', Icons.today, '/tasks'),
      ('複習', Icons.style, '/review'),
      ('日誌', Icons.assignment, '/wellness'),
      ('儀表板', Icons.insights, '/dashboard'),
    ];
    final location = GoRouterState.of(context).uri.toString();
    final idx = tabs.indexWhere((t) => location.startsWith(t.$3));
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx,
        onDestinationSelected: (i) => GoRouter.of(context).go(tabs[i].$3),
        destinations: [
          for (final t in tabs)
            NavigationDestination(icon: Icon(t.$2), label: t.$1),
        ],
      ),
    );
  }
}