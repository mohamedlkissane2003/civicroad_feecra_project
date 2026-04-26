import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../services/civicroad_api.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  static const _filters = ['All', 'Pending', 'In Progress', 'Resolved'];

  String _activeFilter = 'All';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final reports = await CivicRoadApi.fetchPublicReports();
      if (!mounted) return;
      setState(() => _reports = reports);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return AppColors.statusPending;
      case 'in progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusResolved;
      default:
        return AppColors.textSecondary;
    }
  }

  String _normalizeStatus(String status) {
    return status.replaceAll('_', ' ').trim().toLowerCase();
  }

  String _displayStatus(String status) {
    final normalized = _normalizeStatus(status);
    return normalized
        .split(' ')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _displayDate(dynamic createdAt) {
    if (createdAt is! String || createdAt.isEmpty) {
      return 'Recently';
    }

    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return createdAt;
    }

    return '${_monthName(parsed.month)} ${parsed.day}, ${parsed.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, months.length - 1)];
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_activeFilter == 'All') {
      return _reports;
    }

    return _reports.where((report) {
      return _displayStatus(report['status'] as String).toLowerCase() == _activeFilter.toLowerCase();
    }).toList();
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
    final visibleCount = _filteredReports.length;

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
            children: [
              const Text(
                'My Reports',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                '$visibleCount issues shown',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _loading ? null : _loadReports,
              icon: const Icon(Icons.refresh, size: 20, color: AppColors.text),
            ),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 10),
              const Text('Could not load reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary), textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: _loadReports, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final reports = _filteredReports;
    if (reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 10),
            Text('No Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('No reports match the selected filter', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 120),
        itemCount: reports.length,
        itemBuilder: (context, index) => _buildReportCard(reports[index]),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final statusText = _displayStatus((report['status'] as String?) ?? 'pending');
    final statusColor = _statusColor(statusText);
    final imageUrl = report['image_url'] as String?;
    final hasNetworkImage = imageUrl != null && imageUrl.startsWith('http');

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
          Container(
            width: 90,
            height: 110,
            color: AppColors.primary.withValues(alpha: 0.08),
            child: hasNetworkImage
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.image_outlined, size: 28, color: AppColors.primary),
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
                          report['title'] as String? ?? 'Untitled report',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['description'] as String? ?? 'No description provided.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.label_outline, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        report['category'] as String? ?? 'other',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report['location_text'] as String? ?? 'Location unavailable',
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _displayDate(report['created_at']),
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
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
