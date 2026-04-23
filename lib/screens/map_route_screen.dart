import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/app_theme.dart';

class MapRouteScreen extends StatefulWidget {
  final bool embedded;

  const MapRouteScreen({super.key, this.embedded = false});

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  final List<String> _places = const [
    'MG Road',
    'Central Bus Stand',
    'Railway Station',
    'Airport Road',
    'University Circle',
    'City Hospital',
  ];

  String _from = 'MG Road';
  String _to = 'Railway Station';
  bool _safestRoute = true;
  bool _recalculating = false;

  static const Map<String, LatLng> _placeCoordinates = {
    'MG Road': LatLng(12.9758, 77.6055),
    'Central Bus Stand': LatLng(12.9770, 77.5728),
    'Railway Station': LatLng(12.9784, 77.5725),
    'Airport Road': LatLng(13.0060, 77.6068),
    'University Circle': LatLng(12.9435, 77.5734),
    'City Hospital': LatLng(12.9601, 77.5933),
  };

  LatLng _coordFor(String place) {
    return _placeCoordinates[place] ?? const LatLng(12.9716, 77.5946);
  }

  LatLng _midpoint(LatLng a, LatLng b) {
    return LatLng(
        (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
  }

  List<LatLng> _safeRoutePoints(LatLng fromPoint, LatLng toPoint) {
    final mid = _midpoint(fromPoint, toPoint);
    return [
      fromPoint,
      LatLng(mid.latitude + 0.006, mid.longitude - 0.004),
      toPoint,
    ];
  }

  List<LatLng> _fastRoutePoints(LatLng fromPoint, LatLng toPoint) {
    final mid = _midpoint(fromPoint, toPoint);
    return [
      fromPoint,
      LatLng(mid.latitude - 0.004, mid.longitude + 0.003),
      toPoint,
    ];
  }

  void _onFromChanged(String value) {
    setState(() {
      _from = value;
      if (_to == _from) {
        _to = _places.firstWhere(
          (place) => place != _from,
          orElse: () => _to,
        );
      }
    });
  }

  void _onToChanged(String value) {
    if (value == _from) return;
    setState(() => _to = value);
  }

  Future<void> _toggleRouteMode(bool safest) async {
    setState(() {
      _safestRoute = safest;
      _recalculating = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _recalculating = false);
  }

  @override
  Widget build(BuildContext context) {
    final riskScore = _safestRoute ? 0.24 : 0.61;
    final distance = _safestRoute ? '9.2 km' : '7.8 km';
    final eta = _safestRoute ? '24 min' : '18 min';
    final fromPoint = _coordFor(_from);
    final toPoint = _coordFor(_to);
    final mapCenter = _midpoint(fromPoint, toPoint);
    final safeRoute = _safeRoutePoints(fromPoint, toPoint);
    final fastRoute = _fastRoutePoints(fromPoint, toPoint);
    final toOptions = _places.where((place) => place != _from).toList();
    final selectedTo = toOptions.contains(_to)
        ? _to
        : (toOptions.isNotEmpty ? toOptions.first : _to);
    final content = ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Route Planner',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _from,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          prefixIcon: Icon(Icons.trip_origin_rounded),
                        ),
                        items: _places
                            .map(
                              (place) => DropdownMenuItem<String>(
                                value: place,
                                child: Text(place),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          _onFromChanged(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          final oldFrom = _from;
                          _from = _to;
                          _to = oldFrom;
                        });
                      },
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedTo,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          prefixIcon: Icon(Icons.location_on_rounded),
                        ),
                        items: toOptions
                            .map(
                              (place) => DropdownMenuItem<String>(
                                value: place,
                                child: Text(place),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          _onToChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SuggestionChip(label: 'Airport Road'),
                      _SuggestionChip(label: 'City Hospital'),
                      _SuggestionChip(label: 'University Circle'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: mapCenter,
                        initialZoom: 13,
                        minZoom: 5,
                        maxZoom: 18,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.saferoute.ai.prototype',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: safeRoute,
                              color: AppTheme.primaryGreen.withValues(
                                alpha: _safestRoute ? 0.9 : 0.35,
                              ),
                              strokeWidth: _safestRoute ? 6 : 4,
                            ),
                            Polyline(
                              points: fastRoute,
                              color: AppTheme.riskRed.withValues(
                                alpha: _safestRoute ? 0.35 : 0.9,
                              ),
                              strokeWidth: _safestRoute ? 4 : 6,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: fromPoint,
                              width: 110,
                              height: 42,
                              child: _mapMarker(
                                context,
                                icon: Icons.trip_origin_rounded,
                                label: _from,
                              ),
                            ),
                            Marker(
                              point: toPoint,
                              width: 110,
                              height: 42,
                              child: _mapMarker(
                                context,
                                icon: Icons.location_on_rounded,
                                label: _to,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OpenStreetMap',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _legendRoute(
                  context,
                  color: AppTheme.primaryGreen,
                  text: 'Safe Marking Route',
                  selected: _safestRoute,
                ),
                const SizedBox(width: 8),
                _legendRoute(
                  context,
                  color: AppTheme.riskRed,
                  text: 'Fast Marking Route',
                  selected: !_safestRoute,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.bolt_rounded),
              label: Text('Fastest Route'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.shield_rounded),
              label: Text('Safest Route'),
            ),
          ],
          selected: <bool>{_safestRoute},
          onSelectionChanged: (selection) {
            _toggleRouteMode(selection.first);
          },
        ),
        if (_recalculating) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
          const SizedBox(height: 4),
          Text(
            'Recalculating route risk...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route Details',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _metricRow(
                  context,
                  label: 'Risk Score',
                  value: riskScore.toStringAsFixed(2),
                  color:
                      _safestRoute ? AppTheme.primaryGreen : AppTheme.riskRed,
                ),
                _metricRow(context, label: 'Distance', value: distance),
                _metricRow(context, label: 'Estimated Time', value: eta),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _routeOptionCard(
          context,
          title: 'Safest Recommended',
          subtitle: 'Fewer hazards, slightly longer route',
          eta: '24 min',
          distance: '9.2 km',
          risk: '0.24',
          selected: _safestRoute,
          color: AppTheme.primaryGreen,
          onTap: () => _toggleRouteMode(true),
        ),
        const SizedBox(height: 10),
        _routeOptionCard(
          context,
          title: 'Fastest Alternate',
          subtitle: 'Shorter travel, elevated risk zones',
          eta: '18 min',
          distance: '7.8 km',
          risk: '0.61',
          selected: !_safestRoute,
          color: AppTheme.riskRed,
          onTap: () => _toggleRouteMode(false),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Find Safe Route')),
      body: content,
    );
  }

  Widget _mapMarker(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        SizedBox(
          width: 108,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _metricRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _routeOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String eta,
    required String distance,
    required String risk,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? color : Colors.transparent,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text('$subtitle\n$distance • $eta • Risk $risk'),
        isThreeLine: true,
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: color)
            : const Icon(Icons.radio_button_unchecked_rounded),
      ),
    );
  }

  Widget _legendRoute(
    BuildContext context, {
    required Color color,
    required String text,
    required bool selected,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;

  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.place_outlined, size: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}
