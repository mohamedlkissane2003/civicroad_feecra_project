import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CivicRoadLocalState {
  CivicRoadLocalState._();

  static const String _trackedReportIdsKey = 'civicroad_tracked_report_ids';
  static const String _reportSnapshotsKey = 'civicroad_tracked_report_snapshots';
  static const String _userEmailKey = 'civicroad_user_email';

  static Future<void> rememberSubmittedReport(Map<String, dynamic> report) async {
    final reportId = report['id']?.toString();
    if (reportId == null || reportId.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final trackedIds = prefs.getStringList(_trackedReportIdsKey) ?? <String>[];
    if (!trackedIds.contains(reportId)) {
      trackedIds.add(reportId);
      await prefs.setStringList(_trackedReportIdsKey, trackedIds);
    }

    final snapshots = await _readSnapshots(prefs);
    snapshots[reportId] = {
      'id': reportId,
      'title': report['title']?.toString() ?? 'Untitled report',
      'status': report['status']?.toString() ?? 'pending',
      'location_text': report['location_text']?.toString() ?? '',
      'created_at': report['created_at']?.toString() ?? '',
      'category': report['category']?.toString() ?? '',
    };
    await prefs.setString(_reportSnapshotsKey, jsonEncode(snapshots));
  }

  static Future<void> rememberUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<List<Map<String, dynamic>>> buildNotifications(List<Map<String, dynamic>> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final trackedIds = prefs.getStringList(_trackedReportIdsKey) ?? <String>[];
    final snapshots = await _readSnapshots(prefs);
    final notifications = <Map<String, dynamic>>[];

    for (final report in reports) {
      final reportId = report['id']?.toString();
      if (reportId == null || !trackedIds.contains(reportId)) {
        continue;
      }

      final status = _normalizeStatus(report['status']?.toString() ?? 'pending');
      final previousStatus = _normalizeStatus(snapshots[reportId]?['status']?.toString() ?? 'pending');

      if (status != previousStatus && status != 'pending') {
        notifications.add({
          'id': reportId,
          'title': report['title']?.toString() ?? 'Your report',
          'message': _statusMessage(status),
          'status': status,
          'location_text': report['location_text']?.toString() ?? '',
          'updated_at': report['created_at']?.toString() ?? '',
        });
      }

      snapshots[reportId] = {
        'id': reportId,
        'title': report['title']?.toString() ?? 'Untitled report',
        'status': status,
        'location_text': report['location_text']?.toString() ?? '',
        'created_at': report['created_at']?.toString() ?? '',
        'category': report['category']?.toString() ?? '',
      };
    }

    await prefs.setString(_reportSnapshotsKey, jsonEncode(snapshots));
    notifications.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
    return notifications;
  }

  static Future<Map<String, dynamic>> buildProfileSummary(List<Map<String, dynamic>> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final trackedIds = prefs.getStringList(_trackedReportIdsKey) ?? <String>[];
    final snapshots = await _readSnapshots(prefs);
    final trackedReports = reports.where((report) => trackedIds.contains(report['id']?.toString())).toList();

    final latestTracked = trackedReports.isNotEmpty
        ? trackedReports.first
        : snapshots.values.isNotEmpty
            ? snapshots.values.first
            : null;
    final latestTitle = latestTracked?['title']?.toString() ?? 'No recent activity';
    final latestLocation = latestTracked?['location_text']?.toString() ?? '';

    return {
      'submitted': trackedReports.length,
      'pending': trackedReports.where((report) => _normalizeStatus(report['status']?.toString() ?? 'pending') == 'pending').length,
      'inProgress': trackedReports.where((report) => _normalizeStatus(report['status']?.toString() ?? 'pending') == 'in progress').length,
      'resolved': trackedReports.where((report) => _normalizeStatus(report['status']?.toString() ?? 'pending') == 'resolved').length,
      'latestTitle': latestTitle,
      'latestLocation': latestLocation,
      'email': prefs.getString(_userEmailKey),
      'trackedReports': trackedReports,
    };
  }

  static Future<Map<String, Map<String, dynamic>>> _readSnapshots(SharedPreferences prefs) async {
    final raw = prefs.getString(_reportSnapshotsKey);
    if (raw == null || raw.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return <String, Map<String, dynamic>>{};
    }

    return decoded.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), Map<String, dynamic>.from(value));
      }
      return MapEntry(key.toString(), <String, dynamic>{});
    });
  }

  static String _normalizeStatus(String status) {
    return status.replaceAll('_', ' ').trim().toLowerCase();
  }

  static String _statusMessage(String status) {
    switch (status) {
      case 'in progress':
        return 'Your report is now in progress.';
      case 'resolved':
        return 'Your report has been resolved.';
      default:
        return 'Your report status has been updated.';
    }
  }
}