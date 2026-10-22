import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ip.dart' as legacy;

class CrossRoleSyncService {
  static final CrossRoleSyncService _instance = CrossRoleSyncService._internal();
  factory CrossRoleSyncService() => _instance;
  CrossRoleSyncService._internal();

  // Storage Keys
  static const String keyDoctors = 'admin_doctors_data';
  static const String keyAiDirectives = 'admin_ai_directives_data';
  static const String keyPatientsRegistry = 'registered_patients_registry';
  static const String keyDirectivesHistory = 'clinical_directives_history';
  static const String keyTargetQuitRate = 'admin_target_quit_rate';
  static const String keyCostPerDay = 'admin_cost_per_day';

  // =========================================================================
  // 1. ADMIN <-> DOCTOR AUTHENTICATION & REGISTRY
  // =========================================================================

  /// Retrieve all doctors provisioned by Admin
  Future<List<Map<String, String>>> getProvisionedDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyDoctors);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error reading doctors registry: $e');
      return [];
    }
  }

  /// Save or provision a new doctor
  Future<void> saveDoctor(Map<String, String> doctor) async {
    final docs = await getProvisionedDoctors();
    final id = doctor['id'] ?? '';

    final existingIndex = docs.indexWhere((d) => d['id']?.toLowerCase() == id.toLowerCase());
    if (existingIndex >= 0) {
      docs[existingIndex] = doctor;
    } else {
      docs.insert(0, doctor);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDoctors, json.encode(docs));
  }

  /// Update doctor details
  Future<void> updateDoctor(int index, Map<String, String> doctor) async {
    final docs = await getProvisionedDoctors();
    if (index >= 0 && index < docs.length) {
      docs[index] = doctor;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyDoctors, json.encode(docs));
    }
  }

  /// Delete doctor
  Future<void> deleteDoctor(int index) async {
    final docs = await getProvisionedDoctors();
    if (index >= 0 && index < docs.length) {
      docs.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyDoctors, json.encode(docs));
    }
  }

  /// Find doctor details by ID or username
  Future<Map<String, String>?> findDoctor(String doctorId) async {
    final docs = await getProvisionedDoctors();
    final cleanId = doctorId.trim().toLowerCase();
    for (final doc in docs) {
      final id = (doc['id'] ?? '').trim().toLowerCase();
      final name = (doc['name'] ?? '').replaceAll('Dr. ', '').trim().toLowerCase();
      if (id == cleanId || name == cleanId || cleanId.contains(id)) {
        return doc;
      }
    }
    return null;
  }

  /// Authenticate doctor login against provisioned admin credentials
  Future<bool> authenticateDoctor(String username, String password) async {
    final cleanUser = username.trim().toLowerCase();
    final cleanPass = password.trim();

    final docs = await getProvisionedDoctors();
    for (final doc in docs) {
      final id = (doc['id'] ?? '').trim().toLowerCase();
      final name = (doc['name'] ?? '').replaceAll('Dr. ', '').trim().toLowerCase();
      final docPass = (doc['password'] ?? '').trim();

      if (id == cleanUser || name == cleanUser) {
        // If password matches or if password wasn't enforced
        if (docPass.isEmpty || docPass == cleanPass) {
          legacy.doctid = doc['id'] ?? username;
          return true;
        }
      }
    }
    return false;
  }

  // =========================================================================
  // 2. DOCTOR <-> PATIENT DIRECTIVES & PRESCRIPTIONS
  // =========================================================================

  /// Broadcast clinical directive from Doctor to Patient
  Future<void> sendDoctorDirective({
    required String patientUsername,
    required String doctorId,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanPatient = patientUsername.trim().toLowerCase();

    await prefs.setString('patient_doc_msg_$cleanPatient', message);
    await prefs.setString('patient_doc_id_$cleanPatient', doctorId);
    await prefs.setString('patient_doc_time_$cleanPatient', DateTime.now().toIso8601String());

    // Record in historical directives log
    final historyJson = prefs.getString(keyDirectivesHistory);
    List<dynamic> history = [];
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        history = json.decode(historyJson);
      } catch (_) {}
    }

    history.insert(0, {
      'patient': cleanPatient,
      'doctor': doctorId,
      'message': message,
      'time': DateTime.now().toIso8601String(),
    });

    if (history.length > 50) history = history.sublist(0, 50);
    await prefs.setString(keyDirectivesHistory, json.encode(history));
  }

  /// Retrieve active doctor directive for patient
  Future<String?> getDoctorDirectiveForPatient(String patientUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanPatient = patientUsername.trim().toLowerCase();
    return prefs.getString('patient_doc_msg_$cleanPatient');
  }

  // =========================================================================
  // 3. PATIENT <-> DOCTOR & ADMIN TELEMETRY SYNCHRONIZATION
  // =========================================================================

  /// Record live patient progress, cravings, and slips
  Future<void> updatePatientTelemetry({
    required String patientUsername,
    int? smokeFreeDays,
    int? cravingUrge,
    bool? hasReportedSlip,
    String? mood,
    double? moneySaved,
    String? name,
    String? gender,
    int? age,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUser = patientUsername.trim().toLowerCase();

    // 1. Maintain registry of all active patients
    final registryList = prefs.getStringList(keyPatientsRegistry) ?? [];
    if (!registryList.contains(cleanUser)) {
      registryList.add(cleanUser);
      await prefs.setStringList(keyPatientsRegistry, registryList);
    }

    // 2. Load existing telemetry or initialize
    final existingJson = prefs.getString('patient_telemetry_$cleanUser');
    Map<String, dynamic> data = {};
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        data = json.decode(existingJson);
      } catch (_) {}
    }

    if (name != null && name.isNotEmpty) data['name'] = name;
    if (gender != null && gender.isNotEmpty) data['gender'] = gender;
    if (age != null) data['age'] = age;
    if (smokeFreeDays != null) data['smoke_free_days'] = smokeFreeDays;
    if (cravingUrge != null) data['craving_urge'] = cravingUrge;
    if (hasReportedSlip != null) data['has_reported_slip'] = hasReportedSlip;
    if (mood != null && mood.isNotEmpty) data['last_mood'] = mood;
    if (moneySaved != null) data['money_saved'] = moneySaved;
    data['last_updated'] = DateTime.now().toIso8601String();

    await prefs.setString('patient_telemetry_$cleanUser', json.encode(data));
  }

  /// Retrieve telemetry for a specific patient
  Future<Map<String, dynamic>?> getPatientTelemetry(String patientUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUser = patientUsername.trim().toLowerCase();
    final jsonStr = prefs.getString('patient_telemetry_$cleanUser');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Retrieve all registered patients with their synced telemetry
  Future<List<Map<String, dynamic>>> getAllPatientsWithTelemetry() async {
    final prefs = await SharedPreferences.getInstance();
    final registryList = prefs.getStringList(keyPatientsRegistry) ?? [];
    final List<Map<String, dynamic>> result = [];

    for (final username in registryList) {
      final t = await getPatientTelemetry(username);
      if (t != null) {
        result.add({
          'username': username,
          'name': t['name'] ?? username,
          'age': t['age'] ?? 30,
          'gender': t['gender'] ?? 'Male',
          'smoke_free_days': t['smoke_free_days'] ?? 0,
          'craving_urge': t['craving_urge'] ?? 3,
          'has_reported_slip': t['has_reported_slip'] ?? false,
          'last_mood': t['last_mood'] ?? 'Calm',
          'money_saved': t['money_saved'] ?? 0.0,
          'last_updated': t['last_updated'] ?? '',
        });
      }
    }
    return result;
  }

  // =========================================================================
  // 4. ADMIN <-> PATIENT AI DIRECTIVES
  // =========================================================================

  /// Retrieve all active AI directives configured by the Admin
  Future<List<Map<String, String>>> getActiveAiDirectives() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyAiDirectives);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error reading AI directives: $e');
      return [];
    }
  }

  /// Save AI directives
  Future<void> saveAiDirectives(List<Map<String, String>> directives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAiDirectives, json.encode(directives));
  }

  // =========================================================================
  // 5. AGGREGATED COHORT TELEMETRY (USED BY ADMIN & DOCTOR)
  // =========================================================================

  /// Compute aggregate analytics across live patients and doctors
  Future<Map<String, dynamic>> getAggregateAnalytics() async {
    final patients = await getAllPatientsWithTelemetry();
    final doctors = await getProvisionedDoctors();

    int totalDays = 0;
    int successCount = 0;
    int actionCount = 0;
    int maintenanceCount = 0;
    int prepCount = 0;
    int maleCount = 0;
    int femaleCount = 0;

    for (final p in patients) {
      final days = int.tryParse(p['smoke_free_days']?.toString() ?? '0') ?? 0;
      final urge = int.tryParse(p['craving_urge']?.toString() ?? '0') ?? 0;
      final slip = p['has_reported_slip'] == true;
      final gender = (p['gender']?.toString() ?? 'Male').toLowerCase();

      totalDays += days;
      if (gender == 'male') maleCount++;
      if (gender == 'female') femaleCount++;

      if (days >= 30 || (!slip && urge <= 3)) {
        successCount++;
      }

      if (days > 30) {
        maintenanceCount++;
      } else if (days >= 1) {
        actionCount++;
      } else {
        prepCount++;
      }
    }

    final quitRate = patients.isNotEmpty ? (successCount / patients.length) : 0.0;

    return {
      'totalPatients': patients.length,
      'activeDoctors': doctors.length,
      'quitRate': quitRate,
      'totalSmokeFreeDays': totalDays,
      'actionCount': actionCount,
      'maintenanceCount': maintenanceCount,
      'preparationCount': prepCount,
      'malePatients': maleCount,
      'femalePatients': femaleCount,
    };
  }
}
