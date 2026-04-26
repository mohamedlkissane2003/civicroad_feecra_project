import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../app_colors.dart';
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
  final _scrollController = ScrollController();
  final _mapFieldKey = GlobalKey();
  final _mapController = MapController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToMapField() async {
    final context = _mapFieldKey.currentContext;
    if (context == null) {
      return;
    }

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
      });
      _mapController.move(location, 16);
    } catch (_) {
      // Ignore location failures and keep the map usable.
    }
  }

  Future<void> _handleUseGpsRequested() async {
    await _scrollToMapField();
    await _useCurrentLocation();
  }

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
                controller: _scrollController,
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
    final hasSelection = _selectedLocation != null;

    return Container(
      key: _mapFieldKey,
      height: 240,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.mapBg,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              mapController: _mapController,
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
                            child: const Icon(Icons.location_on, color: Colors.red, size: 34),
                          ),
                        ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton.small(
              heroTag: 'map-current-location',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _useCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(
                hasSelection ? 'Pinned location set' : 'Tap map to pin location',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
            ),
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
            onUseGpsRequested: _handleUseGpsRequested,
            afterPhotoWidget: _buildInteractiveMapCard(),
          ),
        ],
      ),
    );
  }
}
