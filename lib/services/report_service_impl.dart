import '../models/hazard_report.dart';
import 'report_service.dart';

class ReportServiceImpl implements ReportService {
  // In-memory storage for MVP (will be replaced with backend later)
  final List<HazardReport> _localReports = [];

  @override
  Future<List<HazardReport>> fetchReports() async {
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return List<HazardReport>.from(_localReports);
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  @override
  Future<void> submitReport(HazardReport report) async {
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      // Add to local storage
      _localReports.insert(0, report);

      print('Report submitted: ${report.id}');
      print('Image path: ${report.imagePath}');
      print('Location: ${report.latitude}, ${report.longitude}');
      print('Location name: ${report.locationName}');
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    }
  }
}
