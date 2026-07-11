import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service = IncidentService();

  List<IncidentReportModel> _reports = [];
  IncidentReportDetailsModel? _currentReportDetail;
  List<String> _incidentTypes = [];

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isSubmitting = false;

  List<IncidentReportModel> get reports => _reports;
  IncidentReportDetailsModel? get currentReportDetail => _currentReportDetail;
  List<String> get incidentTypes => _incidentTypes;

  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isSubmitting => _isSubmitting;

  Future<void> fetchIncidentReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.fetchIncidentReports();
      _reports = list.map((item) => IncidentReportModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching incident reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchIncidentReportDetail(int id) async {
    _isLoadingDetail = true;
    _currentReportDetail = null;
    notifyListeners();

    try {
      final data = await _service.fetchIncidentReportDetail(id);
      _currentReportDetail = IncidentReportDetailsModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching incident report detail: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchIncidentTypes() async {
    try {
      final list = await _service.fetchIncidentTypes();
      _incidentTypes = list;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching incident types: $e');
    }
  }

  Future<void> createIncident(Map<String, dynamic> body) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.createIncidentReport(body);
      await fetchIncidentReports();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> approveIncident(int id) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _service.approveIncidentReport(id);
      await fetchIncidentReportDetail(id);
      await fetchIncidentReports();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> rejectIncident(int id) async {
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _service.rejectIncidentReport(id);
      await fetchIncidentReportDetail(id);
      await fetchIncidentReports();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<String> uploadImage(String filePath) async {
    return await _service.uploadImage(filePath);
  }
}
