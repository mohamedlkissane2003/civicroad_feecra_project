import 'package:flutter/material.dart';
import '../app_colors.dart';

/// CivicRoad — Profile Screen
/// Shows user avatar, reputation score, stats, achievement badges,
/// progress bar, and settings menu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _stats = [
    {'label': 'Submitted', 'value': '24', 'icon': Icons.upload_outlined,       'color': AppColors.primary},
    {'label': 'Validated',  'value': '18', 'icon': Icons.check_circle_outline,  'color': AppColors.success},
    {'label': 'Resolved',   'value': '12', 'icon': Icons.star_border_outlined,  'color': AppColors.warning},
  ];

  static const _achievements = [
    {
      'label': 'First Reporter',
      'desc': 'Submitted your first issue',
      'icon': Icons.bolt_outlined,
      'earned': true,
    },
    {
      'label': 'Community Hero',
      'desc': '10 reports validated by community',
      'icon': Icons.groups_outlined,
      'earned': true,
    },
    {
      'label': 'Problem Solver',
      'desc': '5 of your reports resolved',
      'icon': Icons.check_circle_outline,
      'earned': false,
    },
    {
      'label': 'City Guardian',
      'desc': '50 issues reported',
      'icon': Icons.shield_outlined,
      'earned': false,
    },
  ];

  static const _menuItems = [
    {'label': 'Notifications',   'icon': Icons.notifications_outlined},
    {'label': 'Privacy Settings','icon': Icons.lock_outline},
    {'label': 'Help & Support',  'icon': Icons.help_outline},
    {'label': 'About CivicRoad', 'icon': Icons.info_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildStatsCard(),
              _buildProgressSection(),
              _buildAchievementsSection(),
              _buildMenuSection(),
              const SizedBox(height: 120),
            ],
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'JD',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                ),
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
                  'John Doe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  '@johndoe · Member since 2025',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 4),
                    const Text(
                      '120 pts',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFBBF24)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Rank #42',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(width: 1, height: 50, color: AppColors.border);
          }
          final stat = _stats[i ~/ 2];
          final color = stat['color'] as Color;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat['icon'] as IconData, size: 20, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                Text(
                  stat['label'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Reputation Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('120 / 200 pts to next rank', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                widthFactor: 0.6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                  ),
                ),
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

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('2 of 4 earned', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
            children: _achievements.map((ach) {
              final earned = ach['earned'] as bool;
              return Opacity(
                opacity: earned ? 1.0 : 0.55,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: earned ? AppColors.primary.withOpacity(0.12) : AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              ach['icon'] as IconData,
                              size: 20,
                              color: earned ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          if (!earned)
                            const Icon(Icons.lock_outline, size: 13, color: AppColors.textTertiary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ach['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: earned ? AppColors.text : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ach['desc'] as String,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(_menuItems.length, (i) {
          final item = _menuItems[i];
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, color: AppColors.border),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData, size: 17, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
