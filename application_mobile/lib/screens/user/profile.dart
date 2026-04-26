import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../services/civicroad_api.dart';
import '../../services/civicroad_local_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _summary = const {};
  List<Map<String, dynamic>> _reports = [];

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
      final reports = await CivicRoadApi.fetchPublicReports();
      final summary = await CivicRoadLocalState.buildProfileSummary(reports);
      final email = await CivicRoadLocalState.readUserEmail();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _summary = {...summary, 'email': summary['email'] ?? email};
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

  int _submittedCount() => (_summary['submitted'] as int?) ?? 0;
  int _pendingCount() => (_summary['pending'] as int?) ?? 0;
  int _inProgressCount() => (_summary['inProgress'] as int?) ?? 0;
  int _resolvedCount() => (_summary['resolved'] as int?) ?? 0;

  @override
  Widget build(BuildContext context) {
    final latestTitle = _summary['latestTitle']?.toString() ?? 'No recent activity';
    final latestLocation = _summary['latestLocation']?.toString() ?? '';
    final email = _summary['email']?.toString() ?? 'Citizen account';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(email),
                if (_loading) const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
                if (_error != null) _buildErrorBanner(),
                if (!_loading) ...[
                  _buildStatsCard(),
                  _buildProgressSection(),
                  _buildRecentActivitySection(latestTitle, latestLocation),
                  _buildAchievementsSection(),
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

  Widget _buildProfileHeader(String email) {
    final submitted = _submittedCount();
    final latestTitle = _summary['latestTitle']?.toString() ?? 'No recent activity';

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
                const Text('CivicRoad Citizen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 4),
                    Text('${submitted * 12 + _resolvedCount() * 8} pts', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFBBF24))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text('Rank #${42 - submitted.clamp(0, 20)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$submitted report${submitted == 1 ? '' : 's'} tracked', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.84))),
                Text(latestTitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.72)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = [
      {'label': 'Submitted', 'value': '${_submittedCount()}', 'icon': Icons.upload_outlined, 'color': AppColors.primary},
      {'label': 'Pending', 'value': '${_pendingCount()}', 'icon': Icons.schedule_outlined, 'color': AppColors.warning},
      {'label': 'In Progress', 'value': '${_inProgressCount()}', 'icon': Icons.engineering_outlined, 'color': AppColors.primaryDark},
      {'label': 'Resolved', 'value': '${_resolvedCount()}', 'icon': Icons.check_circle_outline, 'color': AppColors.success},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: List.generate(stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(width: 1, height: 50, color: AppColors.border);
          }
          final stat = stats[i ~/ 2];
          final color = stat['color'] as Color;
          return Expanded(
            child: Column(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(stat['icon'] as IconData, size: 20, color: color)),
                const SizedBox(height: 6),
                Text(stat['value'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text(stat['label'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressSection() {
    final submitted = _submittedCount();
    final resolved = _resolvedCount();
    final progress = submitted == 0 ? 0.0 : (resolved / submitted).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reputation Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('${(progress * 100).toStringAsFixed(0)}% based on resolved reports', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 10,
              color: AppColors.backgroundTertiary,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]))),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contributor', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text('Hero', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(String latestTitle, String latestLocation) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 10),
            Text(latestTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
            if (latestLocation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(latestLocation, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _activityChip('Tracked ${_reports.length}', AppColors.primary),
                _activityChip('${_inProgressCount()} in progress', AppColors.statusInProgress),
                _activityChip('${_resolvedCount()} resolved', AppColors.statusResolved),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildAchievementsSection() {
    final submitted = _submittedCount();
    final earnedCount = [1, 3, 5, 10].where((threshold) => submitted >= threshold).length;

    final achievements = [
      {'label': 'First Reporter', 'desc': 'Submitted your first issue', 'icon': Icons.bolt_outlined, 'threshold': 1},
      {'label': 'Community Hero', 'desc': '3 reports picked up by the city', 'icon': Icons.groups_outlined, 'threshold': 3},
      {'label': 'Problem Solver', 'desc': '5 of your reports resolved', 'icon': Icons.check_circle_outline, 'threshold': 5},
      {'label': 'City Guardian', 'desc': '10 issues reported', 'icon': Icons.shield_outlined, 'threshold': 10},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('$earnedCount of ${achievements.length} earned', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: achievements.map((ach) {
              final earned = submitted >= (ach['threshold'] as int);
              return Opacity(
                opacity: earned ? 1.0 : 0.55,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(color: earned ? AppColors.primary.withValues(alpha: 0.12) : AppColors.border, borderRadius: BorderRadius.circular(10)),
                            child: Icon(ach['icon'] as IconData, size: 20, color: earned ? AppColors.primary : AppColors.textTertiary),
                          ),
                          const Spacer(),
                          if (!earned) const Icon(Icons.lock_outline, size: 13, color: AppColors.textTertiary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(ach['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: earned ? AppColors.text : AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(ach['desc'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.18))),
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