import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_colors.dart';
import 'report.dart';

/// CivicRoad — Home Screen
/// Combines report creation and map overview in a single page.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _agadirCenter = LatLng(30.4278, -9.5981);
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineReportSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CivicRoad',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'San Francisco, CA',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.text),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.backgroundTertiary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMapCard() {
    return Container(
      height: 240,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mapBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: _agadirCenter,
          initialZoom: 13,
          onTap: (_, latLng) {
            setState(() {
              _selectedLocation = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.final_code_feecra',
          ),
          MarkerLayer(
            markers: _selectedLocation == null
                ? const []
                : [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _selectedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 34,
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineReportSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create a Report',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          const SizedBox(height: 10),
          ReportFormSection(
            showHeader: false,
            scrollable: false,
            selectedMapLocation: _selectedLocation,
            afterPhotoWidget: _buildInteractiveMapCard(),
          ),
        ],
      ),
    );
  }
}
