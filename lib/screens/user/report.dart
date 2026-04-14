import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../app_colors.dart';

/// CivicRoad — Report Screen
/// Lets the user upload a photo, pick a problem category, confirm GPS location,
/// add an optional description, choose severity and submit.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ReportFormSection(),
      ),
    );
  }
}

class ReportFormSection extends StatefulWidget {
  const ReportFormSection({
    super.key,
    this.showHeader = true,
    this.scrollable = true,
    this.afterPhotoWidget,
    this.selectedMapLocation,
  });

  final bool showHeader;
  final bool scrollable;
  final Widget? afterPhotoWidget;
  final LatLng? selectedMapLocation;

  @override
  State<ReportFormSection> createState() => _ReportFormSectionState();
}

class _ReportFormSectionState extends State<ReportFormSection> {
  String? _selectedCategory;
  String _selectedSeverity = 'Medium';
  final _descController = TextEditingController();

  static const _categories = [
    {'id': 'pothole',     'label': 'Pothole',          'icon': Icons.circle_notifications_outlined},
    {'id': 'streetlight', 'label': 'Streetlight Out',  'icon': Icons.flashlight_off_outlined},
    {'id': 'garbage',     'label': 'Garbage',          'icon': Icons.delete_outline},
    {'id': 'sidewalk',    'label': 'Broken Sidewalk',  'icon': Icons.straighten_outlined},
    {'id': 'graffiti',    'label': 'Graffiti',         'icon': Icons.brush_outlined},
    {'id': 'flooding',    'label': 'Flooding',         'icon': Icons.water_drop_outlined},
  ];

  static const _severities = ['Low', 'Medium', 'High'];

  Color _severityColor(String level) {
    switch (level) {
      case 'Low':
        return AppColors.success;
      case 'High':
        return AppColors.error;
      case 'Medium':
      default:
        return AppColors.warning;
    }
  }

  String _formatCoordinates(LatLng location) {
    final latValue = location.latitude.abs().toStringAsFixed(6);
    final lngValue = location.longitude.abs().toStringAsFixed(6);
    final latDir = location.latitude >= 0 ? 'N' : 'S';
    final lngDir = location.longitude >= 0 ? 'E' : 'W';
    return '$latValue° $latDir, $lngValue° $lngDir';
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) _buildHeader(),
        _buildPhotoUpload(),
        if (widget.afterPhotoWidget != null) widget.afterPhotoWidget!,
        _buildSectionLabel('Problem Category'),
        _buildCategoryGrid(),
        _buildSectionLabel('GPS Location'),
        _buildLocationCard(),
        _buildSectionLabel('Description (optional)'),
        _buildDescriptionField(),
        _buildSectionLabel('Severity'),
        _buildSeverityRow(),
        _buildSubmitButton(),
        const SizedBox(height: 32),
      ],
    );

    if (widget.scrollable) {
      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    return content;
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Report a Problem',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.5),
          ),
          SizedBox(height: 2),
          Text(
            'Help improve your city',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 2,
              style: BorderStyle.none, // dashed not supported natively; use a package for real dashes
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              const Text('Add a Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
              const SizedBox(height: 4),
              const Text('Take or upload from gallery', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _photoActionBtn(Icons.camera_alt_outlined, 'Camera'),
                    Container(width: 1, height: 36, color: AppColors.border),
                    _photoActionBtn(Icons.photo_library_outlined, 'Gallery'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoActionBtn(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryDark),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
        children: _categories.map((cat) {
          final selected = _selectedCategory == cat['id'] as String;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['id'] as String),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 20,
                      color: selected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationCard() {
    final selectedLocation = widget.selectedMapLocation;
    final coordinateText = selectedLocation != null
    ? _formatCoordinates(selectedLocation)
        : 'No map selection yet';

    final statusText = selectedLocation != null
        ? 'Selected location from map'
        : 'Tap on the map to select location';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coordinateText,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: selectedLocation != null ? AppColors.success : AppColors.textTertiary,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: TextField(
        controller: _descController,
        maxLines: 4,
        style: const TextStyle(fontSize: 14, color: AppColors.text),
        decoration: InputDecoration(
          hintText: 'Describe the problem in detail...',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: _severities.map((level) {
          final isSelected = _selectedSeverity == level;
          final severityColor = _severityColor(level);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: level != 'High' ? 10 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSeverity = level),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? severityColor.withOpacity(0.14) : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? severityColor : AppColors.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? severityColor : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your report will be reviewed and forwarded to the city authority',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
