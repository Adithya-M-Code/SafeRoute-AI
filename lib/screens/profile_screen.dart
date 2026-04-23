import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/hazard_report.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rawList = jsonDecode(MockData.hazardsJson) as List<dynamic>;
    final reports = rawList
        .map((item) => HazardReport.fromJson(item as Map<String, dynamic>))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aditya Sharma',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text('Safety Contributor', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggleTheme,
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
          ),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Profile'),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(child: _miniStat(context, '28', 'Total Reports')),
                Expanded(child: _miniStat(context, '17', 'Verified')),
                Expanded(child: _miniStat(context, '4.8', 'Trust Score')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Notifications, app preferences, privacy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Past Reports', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...reports.map((report) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    Icons.report_gmailerrorred_rounded,
                    color: report.riskScore > 0.7
                        ? AppTheme.riskRed
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text('${report.type} • ${report.location}'),
                  subtitle: Text('${report.status} • ${report.timeAgo}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: report.riskScore > 0.7
                          ? AppTheme.riskRed.withOpacity(0.1)
                          : AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                    child: Text(
                      report.riskScore.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _miniStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
