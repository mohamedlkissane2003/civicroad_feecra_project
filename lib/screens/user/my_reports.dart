import 'package:flutter/material.dart';
import '../app_colors.dart';

/// CivicRoad — My Reports Screen
/// Displays the user's submitted reports with filter tabs and status badges.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String _activeFilter = 'All';

  static const _filters = ['All', 'Pending', 'In Progress', 'Resolved'];

  static const _reports = [
    {
      'id': '1',
      'title': 'Pothole',
      'description': 'Large pothole near bus stop, dangerous for cyclists',
      'street': 'Market St & 5th St',
      'date': 'Mar 20, 2026',
      'status': 'In Progress',
      'votes': 14,
      'color': Color(0xFF475569),
    },
    {
      'id': '2',
      'title': 'Streetlight Out',
      'description': 'Three lights out in a row, block is very dark at night',
      'street': 'Oak Avenue, Block 3',
      'date': 'Mar 18, 2026',
      'status': 'Pending',
      'votes': 8,
      'color': Color(0xFFD97706),
    },
    {
      'id': '3',
      'title': 'Overflowing Garbage',
      'description': 'Public bin overflowing since 3 days, causing smell',
      'street': 'Central Park North',
      'date': 'Mar 15, 2026',
      'status': 'Resolved',
      'votes': 22,
      'color': Color(0xFF16A34A),
    },
    {
      'id': '4',
      'title': 'Broken Sidewalk',
      'description': 'Cracked tiles are a hazard for pedestrians and elderly',
      'street': 'Valencia St, near #204',
      'date': 'Mar 10, 2026',
      'status': 'Resolved',
      'votes': 6,
      'color': Color(0xFF7C3AED),
    },
    {
      'id': '5',
      'title': 'Graffiti on Wall',
      'description': 'Offensive graffiti on school boundary wall',
      'street': 'Mission District, 16th St',
      'date': 'Mar 8, 2026',
      'status': 'Pending',
      'votes': 3,
      'color': Color(0xFFDB2777),
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':     return AppColors.statusPending;
      case 'In Progress': return AppColors.statusInProgress;
      case 'Resolved':    return AppColors.statusResolved;
      default:            return AppColors.textSecondary;
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_activeFilter == 'All') return List<Map<String, dynamic>>.from(_reports);
    return _reports
        .where((r) => r['status'] == _activeFilter)
        .toList()
        .cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(child: _buildReportsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Reports',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.5),
              ),
              SizedBox(height: 2),
              Text(
                '5 issues submitted',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.filter_list, size: 20, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: _filters.map((tab) {
          final active = _activeFilter == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportsList() {
    final filtered = _filteredReports;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_outlined, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 10),
            Text('No Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('No reports match the selected filter', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 120),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildReportCard(filtered[index]),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final statusColor = _statusColor(report['status'] as String);
    final accentColor = report['color'] as Color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 82,
            color: accentColor.withOpacity(0.12),
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_outlined, size: 20, color: accentColor),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report['title'] as String,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report['status'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['description'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report['street'] as String,
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.thumb_up_alt_outlined, size: 11, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        '${report['votes']}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
