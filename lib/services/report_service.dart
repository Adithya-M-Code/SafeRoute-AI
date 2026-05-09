import '../models/hazard_report.dart';

abstract class ReportService {
  Future<List<HazardReport>> fetchReports();

  Future<void> submitReport(HazardReport report);
}
