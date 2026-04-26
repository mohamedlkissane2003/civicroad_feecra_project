import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../services/civicroad_api.dart';
import '../../services/civicroad_local_state.dart';
import 'home_screen.dart';
import 'my_reports.dart';
import 'notifications.dart';
import 'profile.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _unreadNotifications = 0;
  Timer? _notificationSyncTimer;

  static const _screens = [
    HomeScreen(),
    NotificationsScreen(),
    MyReportsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _syncNotifications();
    _notificationSyncTimer = Timer.periodic(const Duration(seconds: 20), (_) => _syncNotifications(silent: true));
  }

  @override
  void dispose() {
    _notificationSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncNotifications({bool silent = false}) async {
    try {
      final reports = await CivicRoadApi.fetchPublicReports();
      await CivicRoadLocalState.buildNotifications(reports);
      final unread = await CivicRoadLocalState.unreadNotificationCount();
      if (!mounted) return;
      setState(() => _unreadNotifications = unread);
    } catch (_) {
      if (!silent) {
        setState(() => _unreadNotifications = _unreadNotifications);
      }
    }
  }

  Future<void> _onDestinationSelected(int index) async {
    if (index == 1) {
      await CivicRoadLocalState.markNotificationsRead();
      if (!mounted) return;
      setState(() {
        _currentIndex = index;
        _unreadNotifications = 0;
      });
      return;
    }
    setState(() => _currentIndex = index);
  }

  Widget _notificationIcon({required bool selected}) {
    final icon = Icon(
      selected ? Icons.notifications : Icons.notifications_outlined,
      color: selected ? AppColors.primary : null,
    );

    if (_unreadNotifications <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -2,
          top: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _notificationIcon(selected: false),
            selectedIcon: _notificationIcon(selected: true),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: AppColors.primary),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
