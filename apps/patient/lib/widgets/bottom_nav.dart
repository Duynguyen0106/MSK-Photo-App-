import 'package:flutter/material.dart';

import '../routes.dart';

/// Primary navigation: Home, Check-in, History, Settings.
class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _destinations = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Home'),
    (
      icon: Icons.add_circle_outline,
      selected: Icons.add_circle,
      label: 'Check-in',
    ),
    (icon: Icons.history_outlined, selected: Icons.history, label: 'History'),
    (
      icon: Icons.settings_outlined,
      selected: Icons.settings,
      label: 'Settings',
    ),
  ];

  /// Route for each tab index.
  static String routeForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.painMap;
      case 2:
        return AppRoutes.history;
      case 3:
        return AppRoutes.settings;
      default:
        return AppRoutes.home;
    }
  }

  /// Tab index for a route, or null when not a tab root.
  static int? indexForRoute(String? route) {
    switch (route) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.history:
        return 2;
      case AppRoutes.settings:
        return 3;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final d in _destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selected),
            label: d.label,
          ),
      ],
    );
  }
}

/// Scaffold wrapper with bottom navigation for tab roots.
class PatientTabScaffold extends StatelessWidget {
  const PatientTabScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: PatientBottomNav(
        currentIndex: currentIndex,
        onSelected: (index) {
          final route = PatientBottomNav.routeForIndex(index);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              route,
              (r) => false,
            );
          }
        },
      ),
    );
  }
}
