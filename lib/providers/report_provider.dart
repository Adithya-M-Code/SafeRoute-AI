import 'package:flutter/foundation.dart';

import '../models/hazard_report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({ReportService? reportService})
      : _reportService = reportService;

  final ReportService? _reportService;
  final List<HazardReport> _reports = <HazardReport>[];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<HazardReport> get reports => List<HazardReport>.unmodifiable(_reports);

  Future<void> loadReports() async {
    if (_reportService == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedReports = await _reportService.fetchReports();
      _reports
        ..clear()
        ..addAll(fetchedReports);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReport(HazardReport report) async {
    if (_reportService == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _reportService.submitReport(report);
      _reports.insert(0, report);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
