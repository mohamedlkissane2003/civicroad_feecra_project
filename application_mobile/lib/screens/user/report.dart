import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../app_colors.dart';
import '../../services/civicroad_api.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: ReportFormSection()),
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
  static const _categories = [
    {'id': 'pothole', 'label': 'Pothole', 'icon': Icons.circle_notifications_outlined, 'keywords': ['pothole', 'hole', 'road', 'crack']},
    {'id': 'streetlight', 'label': 'Streetlight Out', 'icon': Icons.flashlight_off_outlined, 'keywords': ['light', 'streetlight', 'lamp', 'dark']},
    {'id': 'garbage', 'label': 'Garbage', 'icon': Icons.delete_outline, 'keywords': ['garbage', 'trash', 'bin', 'waste']},
    {'id': 'sidewalk', 'label': 'Broken Sidewalk', 'icon': Icons.straighten_outlined, 'keywords': ['sidewalk', 'pavement', 'curb', 'walkway']},
    {'id': 'graffiti', 'label': 'Graffiti', 'icon': Icons.brush_outlined, 'keywords': ['graffiti', 'tag', 'spray']},
    {'id': 'flooding', 'label': 'Flooding', 'icon': Icons.water_drop_outlined, 'keywords': ['flood', 'water', 'drain', 'overflow']},
  ];

  static const _severities = ['Low', 'Medium', 'High'];

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedCategory;
  String _selectedSeverity = 'Medium';
  bool _categoryLocked = false;
  bool _submitting = false;
  bool _loadingLocation = false;
  String? _locationNote;
  LatLng? _currentLocation;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.selectedMapLocation;
    _titleController.addListener(_suggestCategory);
    _descController.addListener(_suggestCategory);
    _bootstrapLocation();
  }

  @override
  void dispose() {
    _titleController.removeListener(_suggestCategory);
    _descController.removeListener(_suggestCategory);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapLocation() async {
    if (widget.selectedMapLocation != null || kIsWeb) {
      return;
    }

    await _captureCurrentLocation();
  }

  void _suggestCategory() {
    if (_categoryLocked || _selectedCategory != null) {
      return;
    }

    final text = '${_titleController.text} ${_descController.text}'.toLowerCase();
    for (final category in _categories) {
      final keywords = category['keywords'] as List<String>;
      if (keywords.any(text.contains)) {
        setState(() => _selectedCategory = category['id'] as String);
        return;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access image source: $error')),
      );
    }
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationNote = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationNote = 'GPS captured automatically';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationNote = 'Using selected map point if available';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  String _coordinatesLabel(LatLng location) {
    final lat = location.latitude.abs().toStringAsFixed(6);
    final lng = location.longitude.abs().toStringAsFixed(6);
    final latDir = location.latitude >= 0 ? 'N' : 'S';
    final lngDir = location.longitude >= 0 ? 'E' : 'W';
    return '$lat° $latDir, $lng° $lngDir';
  }

  String _categoryLabel(String? categoryId) {
    final category = _categories.firstWhere(
      (item) => item['id'] == categoryId,
      orElse: () => _categories.first,
    );
    return category['label'] as String;
  }

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title, description, and category before submitting.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await CivicRoadApi.submitReport(
        title: title,
        description: description,
        category: _selectedCategory!,
        severity: _selectedSeverity,
        userName: 'Citizen Reporter',
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
        location: _currentLocation,
        locationText: _currentLocation != null ? _coordinatesLabel(_currentLocation!) : null,
      );

      if (!mounted) return;
      setState(() {
        _titleController.clear();
        _descController.clear();
        _selectedCategory = null;
        _categoryLocked = false;
        _selectedSeverity = 'Medium';
        _selectedImageBytes = null;
        _selectedImageName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report sent to CivicRoad dashboard.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) _buildHeader(),
        _buildPhotoCard(),
        _buildTitleField(),
        if (widget.afterPhotoWidget != null) widget.afterPhotoWidget!,
        _buildSectionLabel('Problem category'),
        _buildCategoryGrid(),
        _buildSectionLabel('GPS location'),
        _buildLocationCard(),
        _buildSectionLabel('Description'),
        _buildDescriptionField(),
        _buildSectionLabel('Severity'),
        _buildSeverityRow(),
        _buildSubmitButton(),
        const SizedBox(height: 28),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report a Problem', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -0.5)),
          SizedBox(height: 2),
          Text('Photo, GPS, and category flow to the municipal dashboard.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            if (_selectedImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(_selectedImageBytes!, height: 180, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.primary),
              ),
            const SizedBox(height: 12),
            Text(
              _selectedImageBytes != null ? 'Photo attached' : 'Add a photo',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            const SizedBox(height: 4),
            const Text('Take a photo or upload from gallery.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              children: [
                _photoActionButton(Icons.camera_alt_outlined, 'Camera', () => _pickImage(ImageSource.camera)),
                _photoActionButton(Icons.photo_library_outlined, 'Gallery', () => _pickImage(ImageSource.gallery)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoActionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _submitting ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: TextField(
        controller: _titleController,
        textCapitalization: TextCapitalization.sentences,
        decoration: _fieldDecoration('Short issue title'),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: TextField(
        controller: _descController,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: _fieldDecoration('Describe the problem in detail...'),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
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
        childAspectRatio: 1,
        children: _categories.map((category) {
          final selected = _selectedCategory == category['id'];
          return GestureDetector(
            onTap: _submitting
                ? null
                : () => setState(() {
                      _selectedCategory = category['id'] as String;
                      _categoryLocked = true;
                    }),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(category['icon'] as IconData, size: 20, color: selected ? Colors.white : AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['label'] as String,
                    style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary),
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
    final selected = _currentLocation;
    final statusText = selected != null ? 'Selected location will reach the dashboard' : 'Tap the map or use GPS';
    final coordinateText = selected != null ? _coordinatesLabel(selected) : 'No location selected yet';

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
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(_locationNote ?? coordinateText, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            TextButton(
              onPressed: _loadingLocation ? null : _captureCurrentLocation,
              child: Text(_loadingLocation ? 'Locating…' : 'Use GPS'),
            ),
          ],
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
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: level == 'High' ? 0 : 10),
              child: GestureDetector(
                onTap: _submitting ? null : () => setState(() => _selectedSeverity = level),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.14) : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.4 : 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    level,
                    style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textSecondary),
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
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _submitting ? null : _submitReport,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_submitting)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _submitting ? 'Submitting…' : 'Submit Report',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('The report is forwarded to the city dashboard for triage and planning.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Auto-category: ${_categoryLabel(_selectedCategory)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }
}