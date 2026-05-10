import 'dart:io';
import 'package:flutter/material.dart';

import '../models/hazard_report.dart';
import '../services/image_service_impl.dart';
import '../services/location_service_impl.dart';
import '../services/report_service_impl.dart';
import '../utils/app_theme.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  final _locationController =
      TextEditingController(text: 'Detecting location...');
  final _descriptionController = TextEditingController();

  // Services
  late final ImageServiceImpl _imageService;
  late final LocationServiceImpl _locationService;
  late final ReportServiceImpl _reportService;

  // State variables
  String _selectedHazard = 'Pothole';
  double _severity = 3;
  bool _anonymous = false;
  bool _submitting = false;
  String? _selectedImagePath;
  double? _latitude;
  double? _longitude;
  String? _locationName;
  bool _loadingLocation = false;

  final List<String> _hazards = const [
    'Pothole',
    'Waterlogging',
    'Debris',
    'Accident',
    'Construction',
  ];

  @override
  void initState() {
    super.initState();
    _imageService = ImageServiceImpl();
    _locationService = LocationServiceImpl();
    _reportService = ReportServiceImpl();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
        });

        final placemark =
            await _locationService.getPlacemarkFromLocation(location);
        setState(() {
          _locationName = placemark;
          _locationController.text = placemark ?? 'Location detected';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Could not get location. Please check permissions.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _locationController.text = 'Location unavailable';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _locationController.text = 'Location error';
      });
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final imagePath = await _imageService.pickImageFromCamera();
    if (imagePath != null) {
      setState(() => _selectedImagePath = imagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image captured successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await _imageService.pickImageFromGallery();
    if (imagePath != null) {
      setState(() => _selectedImagePath = imagePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location is required. Please enable location services.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final report = HazardReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedHazard,
        location: _locationName ?? _locationController.text,
        status: 'pending_validation',
        timeAgo: 'just now',
        riskScore: _severity / 5.0,
        imagePath: _selectedImagePath,
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationName,
        description: _descriptionController.text,
        severity: _severity,
        anonymous: _anonymous,
      );

      await _reportService.submitReport(report);

      if (!mounted) return;

      // Show success dialog
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon:
              const Icon(Icons.verified_rounded, color: AppTheme.primaryGreen),
          title: const Text('Report Submitted'),
          content: Text(
            'Your $_selectedHazard report has been sent for AI validation. '
            'You can track status in your profile.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryGreen,
            content: Text('Hazard report submitted: $_selectedHazard'),
          ),
        );

        // Reset form
        setState(() {
          _selectedImagePath = null;
          _descriptionController.clear();
          _selectedHazard = 'Pothole';
          _severity = 3;
          _anonymous = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error submitting report: $e'),
          ),
        );
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Hazard')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Image selection card
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _submitting ? null : _showImageSourceDialog,
              child: Container(
                height: 170,
                padding: const EdgeInsets.all(18),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload hazard image',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to add photo (camera or gallery)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Location info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Location Details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      if (_loadingLocation)
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: _loadCurrentLocation,
                          iconSize: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Location Address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_latitude != null && _longitude != null)
                    Text(
                      'Coordinates: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Hazard type dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedHazard,
            decoration: const InputDecoration(
              labelText: 'Hazard type',
              prefixIcon: Icon(Icons.warning_amber_rounded),
            ),
            items: _hazards
                .map(
                  (hazard) => DropdownMenuItem<String>(
                    value: hazard,
                    child: Text(hazard),
                  ),
                )
                .toList(),
            onChanged: _submitting
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedHazard = value);
                    }
                  },
          ),
          const SizedBox(height: 14),

          // Description field
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe hazard size, lane impact, nearby landmark...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 14),

          // Severity and anonymous card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Severity Level',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        _severity.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _severity,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _severity.toStringAsFixed(0),
                    onChanged: _submitting
                        ? null
                        : (value) => setState(() => _severity = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Submit anonymously'),
                    value: _anonymous,
                    onChanged: _submitting
                        ? null
                        : (value) => setState(() => _anonymous = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              disabledBackgroundColor: Colors.grey,
            ),
            onPressed: _submitting ? null : _submitReport,
            icon: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_submitting ? 'Submitting...' : 'Submit Report'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
