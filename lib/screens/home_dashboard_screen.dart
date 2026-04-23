import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../widgets/animated_action_card.dart';
import 'map_route_screen.dart';
import 'report_hazard_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Hello, Rider',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stay informed about road risks today.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Weather advisory: Moderate rain expected at 6 PM. Risk +12% on low roads.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter destination',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const MapRouteScreen(),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Safety Snapshot',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _statTile(
                        context,
                        '12',
                        'Active Hazards',
                        AppTheme.riskRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statTile(
                        context,
                        '68%',
                        'Route Confidence',
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statTile(
                        context,
                        '4',
                        'Nearby Alerts',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedActionCard(
          icon: Icons.report_problem_rounded,
          title: 'Report Hazard',
          subtitle: 'Add pothole, waterlogging, debris and more',
          accentColor: AppTheme.riskRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ReportHazardScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedActionCard(
          icon: Icons.alt_route_rounded,
          title: 'Find Safe Route',
          subtitle: 'Compare fastest vs safest route instantly',
          accentColor: AppTheme.primaryGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const MapRouteScreen(),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Live Alerts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _alertChip(context, Icons.water_drop_rounded, 'Waterlogging • Ring Road'),
              const SizedBox(width: 8),
              _alertChip(context, Icons.construction_rounded, 'Road Work • Metro Link'),
              const SizedBox(width: 8),
              _alertChip(context, Icons.warning_amber_rounded, 'Pothole Cluster • NH48'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Choose safest mode during rain alerts.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.09),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _alertChip(BuildContext context, IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    );
  }
}
