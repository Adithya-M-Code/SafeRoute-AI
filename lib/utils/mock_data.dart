import '../models/hazard_report.dart';

class MockData {
  static const String hazardsJson = '''
[
  {"id":"H-1021","type":"Pothole","location":"MG Road Junction","status":"Verified","timeAgo":"2h ago","riskScore":0.84},
  {"id":"H-1022","type":"Waterlogging","location":"Lake View Street","status":"Under Review","timeAgo":"5h ago","riskScore":0.67},
  {"id":"H-1023","type":"Debris","location":"Ring Road Exit 4","status":"Verified","timeAgo":"1d ago","riskScore":0.58}
]
''';

  static final List<HazardReport> pastReports = <HazardReport>[
    const HazardReport(
      id: 'H-1021',
      type: 'Pothole',
      location: 'MG Road Junction',
      status: 'Verified',
      timeAgo: '2h ago',
      riskScore: 0.84,
    ),
    const HazardReport(
      id: 'H-1022',
      type: 'Waterlogging',
      location: 'Lake View Street',
      status: 'Under Review',
      timeAgo: '5h ago',
      riskScore: 0.67,
    ),
    const HazardReport(
      id: 'H-1023',
      type: 'Debris',
      location: 'Ring Road Exit 4',
      status: 'Verified',
      timeAgo: '1d ago',
      riskScore: 0.58,
    ),
  ];
}
