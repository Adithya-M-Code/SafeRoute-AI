class HazardReport {
  final String id;
  final String type;
  final String location;
  final String status;
  final String timeAgo;
  final double riskScore;

  const HazardReport({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.timeAgo,
    required this.riskScore,
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    return HazardReport(
      id: json['id'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      timeAgo: json['timeAgo'] as String,
      riskScore: (json['riskScore'] as num).toDouble(),
    );
  }
}
