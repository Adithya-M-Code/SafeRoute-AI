import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class RiskHeatmapScreen extends StatefulWidget {
  const RiskHeatmapScreen({super.key});

  @override
  State<RiskHeatmapScreen> createState() => _RiskHeatmapScreenState();
}

class _RiskHeatmapScreenState extends State<RiskHeatmapScreen> {
  String _selectedWindow = '24h';
  String _selectedType = 'All';
  double _riskThreshold = 0.4;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Risk Heatmap',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedWindow,
                decoration: const InputDecoration(labelText: 'Time Window'),
                items: const [
                  DropdownMenuItem(value: '24h', child: Text('Last 24 hours')),
                  DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                  DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedWindow = value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Hazard Type'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Pothole', child: Text('Pothole')),
                  DropdownMenuItem(value: 'Waterlogging', child: Text('Waterlogging')),
                  DropdownMenuItem(value: 'Debris', child: Text('Debris')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Risk Intensity Filter',
                        style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    Text('${(_riskThreshold * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                Slider(
                  value: _riskThreshold,
                  min: 0.1,
                  max: 1,
                  divisions: 9,
                  onChanged: (value) => setState(() => _riskThreshold = value),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _pill('Hotspot 1 • NH48', Colors.red),
                    _pill('Hotspot 2 • Lake View', Colors.orange),
                    _pill('Hotspot 3 • Metro Lane', Colors.yellow.shade700),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.12),
                  Colors.yellow.withOpacity(0.12),
                  Colors.red.withOpacity(0.14),
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 4,
                  right: 2,
                  child: Text('Heatmap Placeholder'),
                ),
                _dot(28, 34, Colors.green),
                _dot(130, 72, Colors.yellow.shade700),
                _dot(210, 180, Colors.red),
                _dot(78, 210, Colors.yellow.shade700),
                _dot(168, 138, Colors.red),
                Positioned(
                  left: 36,
                  top: 110,
                  child: Chip(
                    avatar: const Icon(Icons.warning_rounded, size: 16),
                    label: Text('Threshold ${(100 * _riskThreshold).toStringAsFixed(0)}%'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legend', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _legend('High Risk', Colors.red),
                _legend('Medium Risk', Colors.yellow.shade700),
                _legend('Low Risk', AppTheme.primaryGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.insights_rounded),
            title: const Text('AI Observation (Mock)'),
            subtitle: Text(
              'Highest clustering appears near NH48 service lane for '
              '$_selectedType in $_selectedWindow. '
              'Confidence: ${(72 + (_riskThreshold * 20)).toStringAsFixed(0)}%',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.place_rounded, color: Colors.red),
                title: const Text('NH48 Service Lane'),
                subtitle: const Text('High risk cluster • 14 reports'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Inspect'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.place_rounded, color: Colors.yellow.shade700),
                title: const Text('Lake View Crossing'),
                subtitle: const Text('Medium risk zone • 9 reports'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Inspect'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(double left, double top, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
        ),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}
