class HazardReport {
  final String id;
  final String type;
  final String location;
  final String status;
  final String timeAgo;
  final double riskScore;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? description;
  final double? severity;
  final bool? anonymous;

  const HazardReport({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.timeAgo,
    required this.riskScore,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.locationName,
    this.description,
    this.severity,
    this.anonymous,
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    return HazardReport(
      id: json['id'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      timeAgo: json['timeAgo'] as String,
      riskScore: (json['riskScore'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      description: json['description'] as String?,
      severity: (json['severity'] as num?)?.toDouble(),
      anonymous: json['anonymous'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'location': location,
      'status': status,
      'timeAgo': timeAgo,
      'riskScore': riskScore,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'description': description,
      'severity': severity,
      'anonymous': anonymous,
    };
  }
}
