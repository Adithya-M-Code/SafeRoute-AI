import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/hazard_report.dart';
import 'firebase_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  Future<void> submitReport({
    required String hazardType,
    required String description,
    required int severity,
    required bool anonymous,
    required double latitude,
    required double longitude,
    required String locationName,
    required String imageUrl,
  }) async {
    try {
      debugPrint('📝 Attempting to submit report to Firestore');
      debugPrint('  - Collection: hazard_reports');
      debugPrint('  - HazardType: $hazardType');
      debugPrint('  - Location: $locationName');
      debugPrint('  - Latitude: $latitude, Longitude: $longitude');

      final docRef = await _firestore.collection('hazard_reports').add({
        'hazardType': hazardType,
        'description': description,
        'severity': severity,
        'anonymous': anonymous,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'imageUrl': imageUrl,
        'status': 'submitted',
        'riskScore': severity / 5.0,
        'timeAgo': 'just now',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Report successfully stored with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('❌ Firestore submitReport error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> submitHazardReport(HazardReport report) {
    return submitReport(
      hazardType: report.type,
      description: report.description ?? '',
      severity: report.severity?.round() ?? 1,
      anonymous: report.anonymous ?? false,
      latitude: report.latitude ?? 0,
      longitude: report.longitude ?? 0,
      locationName: report.locationName ?? report.location,
      imageUrl: report.imageUrl ?? '',
    );
  }

  Future<List<HazardReport>> fetchReports() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('hazard_reports')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HazardReport.fromJson({
          'id': doc.id,
          'type': data['hazardType'] ?? '',
          'location': data['locationName'] ?? '',
          'status': data['status'] ?? 'submitted',
          'timeAgo': data['timeAgo'] ?? 'just now',
          'riskScore': (data['riskScore'] as num?)?.toDouble() ??
              ((data['severity'] as num?)?.toDouble() ?? 1) / 5.0,
          'imagePath': null,
          'imageUrl': data['imageUrl'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'locationName': data['locationName'],
          'description': data['description'],
          'severity': data['severity'],
          'anonymous': data['anonymous'],
          'timestamp': data['timestamp'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
      return <HazardReport>[];
    }
  }
}
