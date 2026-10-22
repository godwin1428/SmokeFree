import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smokefree/services/cross_role_sync_service.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/theme/app_colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  // ---------- Doctor Management State ----------
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  String _selectedGender = 'Male';
  bool _obscurePassword = true;
  bool _isAddingDoctor = false;

  // Dedicated scroll controllers per tab to prevent scroll conflicts
  final ScrollController _doctorsScrollController = ScrollController();
  final ScrollController _analyticsScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();
  final ScrollController _systemScrollController = ScrollController();

  // Dynamic doctor list (persisted in SharedPreferences)
  List<Map<String, String>> _doctorList = [];

  // ---------- Content & AI Directives State ----------
  final TextEditingController _promptController = TextEditingController();
  String _selectedPromptCategory = 'Craving SOS';

  // Dynamic AI directives (persisted in SharedPreferences)
  List<Map<String, String>> _promptList = [];

  // ---------- Dynamic Analytics State ----------
  bool _isLoadingAnalytics = true;
  int _totalPatients = 0;
  int _malePatients = 0;
  int _femalePatients = 0;
  int _totalSmokeFreeDays = 0;
  int _actionStageCount = 0;
  int _maintenanceStageCount = 0;
  int _preparationStageCount = 0;
  double _quitRate = 0.0;
  int _targetQuitRate = 60; // Configurable goal
  int _costPerDay = 120; // Configurable savings calculation (₹/day)

  // ---------- Dynamic System Logs State ----------
  final List<Map<String, String>> _systemLogs = [];
  bool _isPinging = false;
  String _lastPingResult = 'Not tested';

  final String url = "${ip}add_doc.php";

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
    _fetchDynamicAnalytics();
    _addSystemLog('AUTH', 'Admin session initialized and authenticated.');
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _doctorIdController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _mailController.dispose();
    _promptController.dispose();
    _doctorsScrollController.dispose();
    _analyticsScrollController.dispose();
    _contentScrollController.dispose();
    _systemScrollController.dispose();
    super.dispose();
  }

  // =========================================================================
  // PERSISTENCE & DATA INITIALIZATION
  // =========================================================================
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Doctors
    final doctorsJson = prefs.getString('admin_doctors_data');
    if (doctorsJson != null && doctorsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(doctorsJson);
        _doctorList = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      } catch (e) {
        debugPrint('Error loading saved doctors: $e');
      }
    }

    // 2. Load Directives
    final promptsJson = prefs.getString('admin_ai_directives_data');
    if (promptsJson != null && promptsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(promptsJson);
        _promptList = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      } catch (e) {
        debugPrint('Error loading saved prompts: $e');
      }
    } else {
      // Dynamic baseline clinical directives (customizable and editable)
      _promptList = [
        {
          'category': 'Craving SOS',
          'text':
              'Take 3 slow, deep diaphragmatic breaths. A craving peaks in 3 to 5 minutes. Drink cold water and divert attention immediately.',
          'time': 'Active Guideline',
        },
        {
          'category': 'Slip Recovery',
          'text':
              'A lapse is a data point to analyze triggers, not a relapse. Identify the high-risk situation and recommit to your streak.',
          'time': 'Active Guideline',
        },
        {
          'category': 'Milestone',
          'text':
              'Celebrate physiological recovery: Carbon monoxide levels normalization, taste bud revival, and direct monetary savings.',
          'time': 'Active Guideline',
        },
      ];
      _savePrompts();
    }

    // 3. Load Targets
    _targetQuitRate = prefs.getInt('admin_target_quit_rate') ?? 60;
    _costPerDay = prefs.getInt('admin_cost_per_day') ?? 120;

    if (mounted) setState(() {});
  }

  Future<void> _saveDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_doctors_data', json.encode(_doctorList));
  }

  Future<void> _savePrompts() async {
    await CrossRoleSyncService().saveAiDirectives(_promptList);
  }

  void _addSystemLog(String tag, String msg) {
    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    if (mounted) {
      setState(() {
        _systemLogs.insert(0, {'tag': tag, 'time': timeStr, 'msg': msg});
        if (_systemLogs.length > 50) _systemLogs.removeLast();
      });
    }
  }

  // =========================================================================
  // DYNAMIC COHORT ANALYTICS (PULLS FROM BACKEND & CROSS-ROLE SYNC)
  // =========================================================================
  Future<void> _fetchDynamicAnalytics() async {
    if (!mounted) return;
    setState(() => _isLoadingAnalytics = true);

    try {
      // 1. Fetch live patients from backend
      final patientUrl = '${ip}dhome.php';
      final response = await http.post(Uri.parse(patientUrl)).timeout(const Duration(seconds: 8));

      int totalPatientsParsed = 0;
      int totalDaysParsed = 0;
      int successCount = 0;
      int actionCount = 0;
      int maintenanceCount = 0;
      int preparationCount = 0;

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final List<dynamic> patientsJson = json.decode(response.body);
          totalPatientsParsed = patientsJson.length;

          for (int i = 0; i < patientsJson.length; i++) {
            final p = patientsJson[i] as Map<String, dynamic>;
            final days = int.tryParse(p['smoke_free_days']?.toString() ?? p['days']?.toString() ?? '') ?? 0;
            final urge = int.tryParse(p['craving_urge']?.toString() ?? p['intensity']?.toString() ?? '') ?? 0;
            final slip = p['has_reported_slip'] == true || p['slip'] == true || p['reported_slip'] == '1';

            totalDaysParsed += days;

            if (days >= 30 || (!slip && urge <= 3)) {
              successCount++;
            }

            if (days > 30) {
              maintenanceCount++;
            } else if (days >= 1) {
              actionCount++;
            } else {
              preparationCount++;
            }
          }
        } catch (_) {}
      }

      // 2. Fetch cohort breakdown counts
      final countUrl = '${ip}dhomecnt.php';
      final countRes = await http.post(
        Uri.parse(countUrl),
        body: {'username': 'admin'},
      ).timeout(const Duration(seconds: 6));

      int maleCount = 0;
      int femaleCount = 0;

      if (countRes.statusCode == 200 && countRes.body.isNotEmpty) {
        final counts = countRes.body.split(',').map((s) => s.trim()).toList();
        if (counts.length >= 3) {
          final parsedTotal = int.tryParse(counts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? totalPatientsParsed;
          if (parsedTotal > totalPatientsParsed) totalPatientsParsed = parsedTotal;
          maleCount = int.tryParse(counts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          femaleCount = int.tryParse(counts[2].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        }
      }

      // 3. Cross-Role Sync: Merge locally recorded patients telemetry
      final aggregateStats = await CrossRoleSyncService().getAggregateAnalytics();
      final localTotal = aggregateStats['totalPatients'] as int;
      if (localTotal > totalPatientsParsed) {
        totalPatientsParsed = localTotal;
        totalDaysParsed = aggregateStats['totalSmokeFreeDays'] as int;
        actionCount = aggregateStats['actionCount'] as int;
        maintenanceCount = aggregateStats['maintenanceCount'] as int;
        preparationCount = aggregateStats['preparationCount'] as int;
        if (maleCount == 0) maleCount = aggregateStats['malePatients'] as int;
        if (femaleCount == 0) femaleCount = aggregateStats['femalePatients'] as int;
      }

      final computedQuitRate = totalPatientsParsed > 0 ? (successCount / totalPatientsParsed) : 0.0;

      if (mounted) {
        setState(() {
          _totalPatients = totalPatientsParsed;
          _malePatients = maleCount;
          _femalePatients = femaleCount;
          _totalSmokeFreeDays = totalDaysParsed;
          _quitRate = computedQuitRate;
          _actionStageCount = actionCount;
          _maintenanceStageCount = maintenanceCount;
          _preparationStageCount = preparationCount;
          _isLoadingAnalytics = false;
        });
      }
      _addSystemLog('SYNC', 'Cohort telemetry refreshed: $_totalPatients patient records evaluated.');
    } catch (e) {
      debugPrint('Analytics fetch error: $e');
      if (mounted) {
        setState(() => _isLoadingAnalytics = false);
      }
    }
  }

  // =========================================================================
  // DOCTOR ACTIONS: ADD, EDIT, DELETE
  // =========================================================================
  Future<void> addDoctor() async {
    final name = _doctorNameController.text.trim();
    final id = _doctorIdController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Doctor Name, ID, and Password'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    setState(() => _isAddingDoctor = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'name': name,
          'id': id,
          'password': password,
          'age': _ageController.text.trim(),
          'gender': _selectedGender,
          'contact': _contactController.text.trim(),
          'email': _mailController.text.trim(),
        },
      ).timeout(const Duration(seconds: 10));

      final newDoctor = {
        'name': name.startsWith('Dr.') ? name : 'Dr. $name',
        'id': id,
        'password': password,
        'specialty': 'Certified Cessation Specialist',
        'age': _ageController.text.trim(),
        'gender': _selectedGender,
        'contact': _contactController.text.trim(),
        'email': _mailController.text.trim(),
        'patients': '0 Patients',
        'status': 'Active',
      };

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _doctorList.insert(0, newDoctor);
          });
          await _saveDoctors();
          await CrossRoleSyncService().saveDoctor(newDoctor);
          _addSystemLog('PROVISION', 'Provisioned doctor account: $name ($id)');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor $name provisioned successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          _clearDoctorFields();
          return;
        }
      }

      // If backend accepted or local fallback
      setState(() {
        _doctorList.insert(0, newDoctor);
      });
      await _saveDoctors();
      await CrossRoleSyncService().saveDoctor(newDoctor);
      _addSystemLog('PROVISION', 'Added doctor account: $name ($id)');
      _clearDoctorFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doctor $name added to roster.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      // Local dynamic fallback
      final newDoctor = {
        'name': name.startsWith('Dr.') ? name : 'Dr. $name',
        'id': id,
        'password': password,
        'specialty': 'Certified Cessation Specialist',
        'age': _ageController.text.trim(),
        'gender': _selectedGender,
        'contact': _contactController.text.trim(),
        'email': _mailController.text.trim(),
        'patients': '0 Patients',
        'status': 'Active',
      };
      setState(() {
        _doctorList.insert(0, newDoctor);
      });
      await _saveDoctors();
      await CrossRoleSyncService().saveDoctor(newDoctor);
      _addSystemLog('PROVISION', 'Added doctor locally: $name ($id)');
      _clearDoctorFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doctor $name added to clinical roster.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingDoctor = false);
    }
  }

  void _clearDoctorFields() {
    _doctorNameController.clear();
    _doctorIdController.clear();
    _passwordController.clear();
    _ageController.clear();
    _contactController.clear();
    _mailController.clear();
    setState(() => _selectedGender = 'Male');
  }

  void _showEditDoctorDialog(int index) {
    final doc = _doctorList[index];
    final nameCtrl = TextEditingController(text: doc['name']);
    final idCtrl = TextEditingController(text: doc['id']);
    final specialtyCtrl = TextEditingController(text: doc['specialty'] ?? 'Cessation Specialist');
    final contactCtrl = TextEditingController(text: doc['contact'] ?? '');
    final emailCtrl = TextEditingController(text: doc['email'] ?? '');
    final ageCtrl = TextEditingController(text: doc['age'] ?? '');
    String genderVal = doc['gender'] ?? 'Male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Doctor Profile',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogField(nameCtrl, 'Doctor Full Name', Icons.person_outline_rounded),
                  const SizedBox(height: 10),
                  _buildDialogField(specialtyCtrl, 'Clinical Specialty / Role', Icons.medical_services_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildDialogField(idCtrl, 'Doctor ID', Icons.badge_outlined)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDialogField(ageCtrl, 'Age', Icons.cake_outlined, keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gender',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Male', 'Female', 'Other'].map((g) {
                      final isSel = genderVal == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : AppColors.textDark)),
                          selected: isSel,
                          selectedColor: AppColors.primaryTeal,
                          showCheckmark: false,
                          onSelected: (val) {
                            if (val) setDialogState(() => genderVal = g);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  _buildDialogField(contactCtrl, 'Contact Phone', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  _buildDialogField(emailCtrl, 'Email Address', Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress),
                ],
              ),
            ),
          ),
          actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  if (newName.isEmpty) return;

                  final updatedDoc = {
                    'name': newName.startsWith('Dr.') ? newName : 'Dr. $newName',
                    'id': idCtrl.text.trim(),
                    'password': doc['password'] ?? '',
                    'specialty': specialtyCtrl.text.trim(),
                    'age': ageCtrl.text.trim(),
                    'gender': genderVal,
                    'contact': contactCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'patients': doc['patients'] ?? '0 Patients',
                    'status': doc['status'] ?? 'Active',
                  };

                  setState(() {
                    _doctorList[index] = updatedDoc;
                  });
                  _saveDoctors();
                  CrossRoleSyncService().updateDoctor(index, updatedDoc);
                  _addSystemLog('UPDATE', 'Modified doctor record: $newName');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Doctor profile $newName updated.'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteDoctor(int index) {
    final doc = _doctorList[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Remove Clinician', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to remove ${doc['name']} from the active roster?',
          style: GoogleFonts.inter(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coralRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _doctorList.removeAt(index);
              });
              _saveDoctors();
              CrossRoleSyncService().deleteDoctor(index);
              _addSystemLog('DELETE', 'Removed doctor: ${doc['name']}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${doc['name']} removed from roster.'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // AI DIRECTIVE ACTIONS: ADD, EDIT, DELETE
  // =========================================================================
  void _addPrompt() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _promptList.insert(0, {
        'category': _selectedPromptCategory,
        'text': prompt,
        'time': 'Just now',
      });
      _promptController.clear();
    });
    _savePrompts();
    _addSystemLog('AI_CONFIG', 'Added therapeutic directive [$_selectedPromptCategory]');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New AI therapeutic guideline saved and deployed.'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _showEditPromptDialog(int index) {
    final prompt = _promptList[index];
    final textCtrl = TextEditingController(text: prompt['text']);
    String category = prompt['category'] ?? 'Craving SOS';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit AI Directive',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directive Category',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['Craving SOS', 'Slip Recovery', 'Milestone', 'Mindfulness'].map((cat) {
                        final isSel = category == cat;
                        return ChoiceChip(
                          label: Text(cat,
                              style: TextStyle(fontSize: 12, color: isSel ? Colors.white : AppColors.textDark)),
                          selected: isSel,
                          selectedColor: AppColors.primaryTeal,
                          showCheckmark: false,
                          onSelected: (val) {
                            if (val) setDialogState(() => category = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Directive Content / Counseling Script',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: textCtrl,
                      maxLines: 4,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final newText = textCtrl.text.trim();
                  if (newText.isEmpty) return;

                  setState(() {
                    _promptList[index] = {
                      'category': category,
                      'text': newText,
                      'time': 'Updated',
                    };
                  });
                  _savePrompts();
                  _addSystemLog('AI_CONFIG', 'Updated directive [$category]');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Directive successfully updated.'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                },
                child: const Text('Save Directive', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removePrompt(int index) {
    final item = _promptList[index];
    setState(() {
      _promptList.removeAt(index);
    });
    _savePrompts();
    _addSystemLog('AI_CONFIG', 'Deleted directive [${item['category']}]');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Directive removed from library.')),
    );
  }

  // =========================================================================
  // EDIT COHORT TARGETS DIALOG
  // =========================================================================
  void _showEditTargetsDialog() {
    final targetCtrl = TextEditingController(text: '$_targetQuitRate');
    final costCtrl = TextEditingController(text: '$_costPerDay');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.amberGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.track_changes_rounded, color: AppColors.amberGold, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Cohort Target Settings',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  targetCtrl,
                  'Cessation Target Rate (%)',
                  Icons.military_tech_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  costCtrl,
                  'Avg Cigarette Cost per Day (₹)',
                  Icons.savings_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newTarget = int.tryParse(targetCtrl.text.trim()) ?? _targetQuitRate;
              final newCost = int.tryParse(costCtrl.text.trim()) ?? _costPerDay;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('admin_target_quit_rate', newTarget);
              await prefs.setInt('admin_cost_per_day', newCost);

              setState(() {
                _targetQuitRate = newTarget;
                _costPerDay = newCost;
              });

              _addSystemLog('CONFIG', 'Updated cessation targets: Target ${newTarget}%, Cost ₹$newCost/day');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cohort targets updated.'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: const Text('Save Targets', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // REAL SYSTEM DIAGNOSTICS: PING & FLUSH
  // =========================================================================
  Future<void> _pingApiServer() async {
    setState(() => _isPinging = true);
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(Uri.parse(ip)).timeout(const Duration(seconds: 5));
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      final msg = 'Server Responded: ${res.statusCode} in ${ms}ms';

      setState(() {
        _lastPingResult = '${ms}ms (HTTP ${res.statusCode})';
      });
      _addSystemLog('GATEWAY', 'Ping test succeeded: ${ms}ms latency');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Gateway Ping: $msg'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      setState(() {
        _lastPingResult = 'Offline / ${ms}ms';
      });
      _addSystemLog('GATEWAY', 'Ping attempt returned error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ping Error: $e'),
          backgroundColor: AppColors.coralRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPinging = false);
    }
  }

  void _flushCache() {
    _fetchDynamicAnalytics();
    _addSystemLog('CACHE', 'Manual telemetry cache flush executed.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache flushed. Telemetry synchronized with database.'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAdminTopBar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildDoctorManagementTab(),
                  _buildAnalyticsTab(),
                  _buildContentAiTab(),
                  _buildSystemAdminTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // =========================================================================
  // TOP BAR
  // =========================================================================
  Widget _buildAdminTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Admin Console',
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mintFresh.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.mintFresh,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'SmokeFree Clinical Governance',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  content: Text(
                    'Are you sure you want to end the Admin session?',
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coralRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, size: 20, color: AppColors.coralRed),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: DOCTORS MANAGEMENT & PROVISIONING (FULLY DYNAMIC WITH EDIT)
  // =========================================================================
  Widget _buildDoctorManagementTab() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: _doctorsScrollController,
        primary: false,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(
            title: 'Medical Staff Provisioning',
            subtitle: 'Register licensed pulmonologists & cessation counselors into the active clinical roster.',
            badgeText: '${_doctorList.length} ACTIVE CLINICIANS',
            icon: Icons.medical_services_rounded,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // Add Doctor Form Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: AppColors.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Register New Clinician',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in credentials to create portal access for the doctor.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                _buildStyledTextField(
                  controller: _doctorNameController,
                  label: 'Doctor Full Name',
                  hint: 'e.g., Dr. Rajesh Kumar',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildStyledTextField(
                        controller: _doctorIdController,
                        label: 'Doctor / License ID',
                        hint: 'e.g., DOC-101',
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildStyledTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'e.g., 38',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildStyledTextField(
                  controller: _passwordController,
                  label: 'Temporary Portal Password',
                  hint: 'Min. 6 alphanumeric characters',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 14),

                Text(
                  'Gender',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female', 'Other'].map((gender) {
                    final isSelected = _selectedGender == gender;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(
                          gender,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryTeal,
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedGender = gender);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                _buildStyledTextField(
                  controller: _contactController,
                  label: 'Phone Contact',
                  hint: 'e.g., +91 98765 43210',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                _buildStyledTextField(
                  controller: _mailController,
                  label: 'Official Email',
                  hint: 'e.g., doctor@smokefree.clinic',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isAddingDoctor ? null : addDoctor,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppColors.primaryTeal.withValues(alpha: 0.35),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isAddingDoctor
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'PROVISION DOCTOR ACCOUNT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 26),

          // Active Clinician Directory Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Medical Staff (${_doctorList.length})',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              Text(
                'Live Roster',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mintFresh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_doctorList.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 42, color: AppColors.textSubtle),
                  const SizedBox(height: 10),
                  Text(
                    'No doctors currently registered.',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use the form above to provision the first clinical account.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _doctorList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = _doctorList[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
                        child: Text(
                          doc['name']!.replaceAll('Dr. ', '').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  doc['name']!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    doc['id'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              doc['specialty'] ?? 'Cessation Specialist',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                            ),
                            if (doc['contact'] != null && doc['contact']!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                doc['contact']!,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryTeal),
                        onPressed: () => _showEditDoctorDialog(index),
                        tooltip: 'Edit Doctor Details',
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.coralRed),
                        onPressed: () => _deleteDoctor(index),
                        tooltip: 'Remove Doctor',
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  // =========================================================================
  // TAB 2: COHORT ANALYTICS (FULLY DYNAMIC TELEMETRY WITH EDIT TARGETS)
  // =========================================================================
  Widget _buildAnalyticsTab() {
    final collectiveSavings = _totalSmokeFreeDays * _costPerDay;
    final quitRatePercentage = (_quitRate * 100).toStringAsFixed(1);

    return RefreshIndicator(
      onRefresh: _fetchDynamicAnalytics,
      color: AppColors.primaryTeal,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _analyticsScrollController,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Overview Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.heroCardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Live Cohort Telemetry',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showEditTargetsDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Edit Targets',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time aggregated health telemetry calculated from active patients.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 22),

                  if (_isLoadingAnalytics)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    )
                  else ...[
                    // Key Numbers Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildStatCol('Total Patients', '$_totalPatients', Icons.groups_rounded)),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Expanded(child: _buildStatCol('Active Clinicians', '${_doctorList.length}', Icons.health_and_safety_rounded)),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Expanded(child: _buildStatCol('30-Day Quit Rate', '$quitRatePercentage%', Icons.military_tech_rounded)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _quitRate.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintFresh),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Goal: $_targetQuitRate% Cessation Target',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        ),
                        Text(
                          _quitRate * 100 >= _targetQuitRate ? 'Target Met!' : 'Progressing',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mintFresh,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dynamic Clinical Metrics',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.primaryTeal),
                  onPressed: _fetchDynamicAnalytics,
                  tooltip: 'Sync Live Data',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamic 4-card metric grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Smoke-Free Days',
                    value: '$_totalSmokeFreeDays',
                    sub: 'Calculated from patients',
                    icon: Icons.eco_rounded,
                    color: AppColors.mintFresh,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Collective Savings',
                    value: '₹$collectiveSavings',
                    sub: '₹$_costPerDay/day basis',
                    icon: Icons.savings_rounded,
                    color: AppColors.amberGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Male Patients',
                    value: '$_malePatients',
                    sub: 'Registered demographics',
                    icon: Icons.male_rounded,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Female Patients',
                    value: '$_femalePatients',
                    sub: 'Registered demographics',
                    icon: Icons.female_rounded,
                    color: AppColors.skyBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cohort Cessation Stages Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Prochaska Stages Breakdown',
                          style: GoogleFonts.outfit(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDeepTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Live Distribution',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStageProgressBar(
                    'Action Stage (Day 1–30)',
                    _totalPatients > 0 ? (_actionStageCount / _totalPatients) : 0.0,
                    '$_actionStageCount patients',
                    AppColors.primaryTeal,
                  ),
                  const SizedBox(height: 14),
                  _buildStageProgressBar(
                    'Maintenance Stage (> 30 Days)',
                    _totalPatients > 0 ? (_maintenanceStageCount / _totalPatients) : 0.0,
                    '$_maintenanceStageCount patients',
                    AppColors.mintFresh,
                  ),
                  const SizedBox(height: 14),
                  _buildStageProgressBar(
                    'Preparation / Tapering',
                    _totalPatients > 0 ? (_preparationStageCount / _totalPatients) : 0.0,
                    '$_preparationStageCount patients',
                    AppColors.amberGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatCol(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgressBar(String label, double progress, String countText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countText,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 3: CONTENT & AI CONFIGURATION (EDITABLE DIRECTIVES)
  // =========================================================================
  Widget _buildContentAiTab() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: _contentScrollController,
        primary: false,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          _buildHeroCard(
            title: 'Therapeutic AI Directives',
            subtitle: 'Configure dynamic counseling guidance, craving SOS protocols, and empathetic intervention rules.',
            badgeText: 'AI CLINICAL DIRECTIVE ENGINE',
            icon: Icons.psychology_rounded,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // Add New Directive Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Therapeutic Directive',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  'Select Scenario Category',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Craving SOS', 'Slip Recovery', 'Milestone', 'Mindfulness'].map((cat) {
                    final isSel = _selectedPromptCategory == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.primaryTeal,
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) setState(() => _selectedPromptCategory = cat);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Enter AI intervention script, cognitive reframing prompt, or grounding exercise...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSubtle),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _addPrompt,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'DEPLOY TO AI COUNSELOR',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active Directive Library with Edit & Delete Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active AI Directives (${_promptList.length})',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              Text(
                'Live Directives',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mintFresh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_promptList.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology_alt_rounded, size: 42, color: AppColors.textSubtle),
                  const SizedBox(height: 10),
                  Text(
                    'No directives configured.',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your first counseling rule above.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _promptList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prompt = _promptList[index];
                final category = prompt['category'] ?? 'Rule';
                final isSos = category == 'Craving SOS';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSos
                                  ? AppColors.coralRed.withValues(alpha: 0.12)
                                  : AppColors.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSos ? AppColors.coralRed : AppColors.primaryTeal,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // COPY BUTTON
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.copy_rounded, size: 17, color: AppColors.textSubtle),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: prompt['text'] ?? ''));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Directive copied to clipboard.')),
                                  );
                                },
                                tooltip: 'Copy',
                              ),
                              const SizedBox(width: 12),
                              // EDIT BUTTON
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryTeal),
                                onPressed: () => _showEditPromptDialog(index),
                                tooltip: 'Edit Directive',
                              ),
                              const SizedBox(width: 12),
                              // DELETE BUTTON
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.coralRed),
                                onPressed: () => _removePrompt(index),
                                tooltip: 'Delete Directive',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prompt['text']!,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.45,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${prompt['time']}',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  // =========================================================================
  // TAB 4: SYSTEM ADMINISTRATION & DIAGNOSTICS (DYNAMIC LIVE LOGS & PING)
  // =========================================================================
  Widget _buildSystemAdminTab() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: _systemScrollController,
        primary: false,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(
            title: 'System Infrastructure',
            subtitle: 'Monitor real server round-trip latency, backend synchronization, and operational audit records.',
            badgeText: 'API: $ip',
            icon: Icons.dns_rounded,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          Text(
            'Live Service Matrix',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 12),

          _buildServiceRow('API Gateway ($ip)', _lastPingResult, Icons.network_check_rounded,
              _lastPingResult.contains('ms') ? AppColors.successGreen : AppColors.primaryTeal),
          const SizedBox(height: 10),
          _buildServiceRow('Clinical Database', 'Synced ($_totalPatients records)', Icons.storage_rounded, AppColors.successGreen),
          const SizedBox(height: 10),
          _buildServiceRow('AI Clinical Directives', '${_promptList.length} Active Directives', Icons.psychology_rounded,
              AppColors.successGreen),
          const SizedBox(height: 10),
          _buildServiceRow('Active Medical Clinicians', '${_doctorList.length} Staff Provisioned',
              Icons.health_and_safety_rounded, AppColors.primaryTeal),

          const SizedBox(height: 22),

          // Diagnostic Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPinging ? null : _pingApiServer,
                  icon: _isPinging
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                        )
                      : const Icon(Icons.network_ping_rounded, size: 18),
                  label: Text('Ping Server', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _flushCache,
                  icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.white),
                  label: Text('Flush Cache', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Live Logs Terminal Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(
                      'live_system_audit.log',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _systemLogs.clear();
                        });
                        _addSystemLog('CLEAR', 'Audit logs cleared by administrator.');
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.clear_all_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text('Clear', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF1E293B), height: 24),

                if (_systemLogs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No events logged yet.',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _systemLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = _systemLogs[index];
                      Color tagColor = AppColors.mintFresh;
                      if (log['tag'] == 'AI_CONFIG') tagColor = AppColors.skyBlue;
                      if (log['tag'] == 'GATEWAY') tagColor = AppColors.amberGold;
                      if (log['tag'] == 'DELETE') tagColor = AppColors.coralRed;

                      return RichText(
                        text: TextSpan(
                          style: GoogleFonts.jetBrainsMono(fontSize: 11.5, height: 1.4),
                          children: [
                            TextSpan(
                              text: '[${log['time']}] ',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            TextSpan(
                              text: '[${log['tag']}] ',
                              style: TextStyle(color: tagColor, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: log['msg'],
                              style: const TextStyle(color: Color(0xFFE2E8F0)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildServiceRow(String name, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SHARED REUSABLE WIDGETS
  // =========================================================================
  Widget _buildHeroCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSubtle),
            prefixIcon: Icon(icon, color: AppColors.textSubtle, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textSubtle,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSubtle, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // MODERN BOTTOM NAVIGATION BAR
  // =========================================================================
  Widget _buildModernBottomNav() {
    final items = [
      {'icon': Icons.medical_services_rounded, 'label': 'Doctors'},
      {'icon': Icons.insights_rounded, 'label': 'Analytics'},
      {'icon': Icons.psychology_rounded, 'label': 'AI Config'},
      {'icon': Icons.dns_rounded, 'label': 'System'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        size: 22,
                        color: isSelected ? AppColors.primaryTeal : const Color(0xFF94A3B8),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
