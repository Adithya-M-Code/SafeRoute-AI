import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../utils/app_theme.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  final _locationController = TextEditingController(text: 'Current Location');
  final _descriptionController = TextEditingController();
  String _selectedHazard = 'Pothole';
  double _severity = 3;
  bool _anonymous = false;
  bool _submitting = false;

  final List<String> _hazards = const [
    'Pothole',
    'Waterlogging',
    'Debris',
    'Accident',
    'Construction',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(AppConstants.reportSubmitDelay);
    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.verified_rounded, color: AppTheme.primaryGreen),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Hazard report submitted: $_selectedHazard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Hazard')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Image picker is mocked in UI.')),
                );
              },
              child: Container(
                height: 170,
                padding: const EdgeInsets.all(18),
                child: Column(
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
                      'Tap to add photo (mock placeholder)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location_rounded),
                onPressed: () {
                  _locationController.text = 'Auto-detected: Sector 21 Main Rd';
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
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
            onChanged: (value) {
              if (value != null) setState(() => _selectedHazard = value);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe hazard size, lane impact, nearby landmark...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 14),
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
                    onChanged: (value) => setState(() => _severity = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Submit anonymously'),
                    value: _anonymous,
                    onChanged: (value) => setState(() => _anonymous = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _submitting ? null : _submitReport,
            icon: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_submitting ? 'Submitting...' : 'Submit Report'),
          ),
        ],
      ),
    );
  }
}
