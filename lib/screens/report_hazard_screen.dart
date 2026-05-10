import 'dart:io' as io;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/image_service_impl.dart';
import '../services/location_service_impl.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
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
  late final StorageService _storageService;
  late final ReportService _reportService;

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
    _storageService = StorageService();
    _reportService = ReportService();
    // Skip location loading on web platform (not supported)
    if (!kIsWeb) {
      _loadCurrentLocation();
    }
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

    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hazard image before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Upload image with 30-second timeout
      print('\n🖼️ STARTING REPORT SUBMISSION');
      print('🖼️ Step 1: Uploading image...');

      String imageUrl = '';
      try {
        final uploadFuture =
            _storageService.uploadImage(io.File(_selectedImagePath!));
        print('🚀 Image upload task created, waiting...');

        final uploadedUrl = await uploadFuture.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print(
                '⏱️ TIMEOUT: Image upload timed out after 30 seconds - continuing without image');
            return null;
          },
        );

        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          imageUrl = uploadedUrl;
          print('✅ Image uploaded successfully: $imageUrl');
        } else {
          print('⚠️ Image upload returned null/empty');
        }
      } catch (uploadError) {
        print('❌ IMAGE UPLOAD ERROR CAUGHT:');
        print('   Type: ${uploadError.runtimeType}');
        print('   Message: $uploadError');
        print('   ⚠️ Continuing without image...');
        imageUrl = '';
      }

      // Submit to Firestore with 20-second timeout
      print('📝 Step 2: Submitting report to Firestore...');
      try {
        final submitFuture = _reportService.submitReport(
          hazardType: _selectedHazard,
          description: _descriptionController.text,
          severity: _severity.round(),
          anonymous: _anonymous,
          latitude: _latitude!,
          longitude: _longitude!,
          locationName: _locationName ?? _locationController.text,
          imageUrl: imageUrl,
        );

        await submitFuture.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
                'Firestore submission timed out after 20 seconds');
          },
        );

        print('✅ Report submitted successfully!');
      } catch (e) {
        print('❌ Firestore error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Submission failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _submitting = false);
        return;
      }

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
      print('❌ Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error submitting report: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Hazard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
                        child: kIsWeb
                            ? Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('Image selected'),
                                ),
                              )
                            : Image.file(
                                io.File(_selectedImagePath!),
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
          const SizedBox(height: 12),

          // Location info card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: _loadCurrentLocation,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _locationController,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Location Address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_latitude != null && _longitude != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        'Coordinates: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

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
          const SizedBox(height: 12),

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
          const SizedBox(height: 12),

          // Severity and anonymous card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          const SizedBox(height: 16),

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
