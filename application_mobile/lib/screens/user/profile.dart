import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../services/civicroad_local_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  String _email = 'Citizen account';
  int _totalNotifications = 0;
  int _unreadNotifications = 0;

  static const _menuItems = [
    {'label': 'Notifications', 'icon': Icons.notifications_outlined},
    {'label': 'Privacy Settings', 'icon': Icons.lock_outline},
    {'label': 'Help & Support', 'icon': Icons.help_outline},
    {'label': 'About CivicRoad', 'icon': Icons.info_outline},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = await CivicRoadLocalState.readUserEmail();
      final summary = await CivicRoadLocalState.notificationSummary();
      if (!mounted) return;
      setState(() {
        _email = (email == null || email.trim().isEmpty) ? 'Citizen account' : email.trim();
        _totalNotifications = summary['total'] ?? 0;
        _unreadNotifications = summary['unread'] ?? 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                if (_loading) const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
                if (_error != null) _buildErrorBanner(),
                if (!_loading) ...[
                  _buildAccountCard(),
                  _buildActivityCard(),
                  _buildMenuSection(),
                ],
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CivicRoad Citizen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(_email, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.78))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                  child: const Text('Account active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 10),
          _buildInfoRow('Email', _email),
          const SizedBox(height: 8),
          _buildInfoRow('Role', 'Citizen reporter'),
          const SizedBox(height: 8),
          _buildInfoRow('Status', 'Verified and active'),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _activityStat('Notifications', '$_totalNotifications', AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _activityStat('Unread', '$_unreadNotifications', AppColors.error)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Report details are available in the Reports page.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _activityStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(_menuItems.length, (i) {
          final item = _menuItems[i];
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(10)),
                  child: Icon(item['icon'] as IconData, size: 18, color: AppColors.textSecondary),
                ),
                title: Text(item['label'] as String, style: const TextStyle(fontSize: 14, color: AppColors.text)),
                trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
                onTap: () {},
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          TextButton(onPressed: _loadProfile, child: const Text('Retry')),
        ],
      ),
    );
  }
}
