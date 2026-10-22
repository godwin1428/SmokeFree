import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smokefree/secondpage.dart';
import 'package:smokefree/services/cross_role_sync_service.dart';
import 'package:smokefree/theme/app_colors.dart';
import 'package:smokefree/ip.dart';

class DoctorProfilePage extends StatefulWidget {
  final String username;

  const DoctorProfilePage({super.key, required this.username});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  String _name = '';
  String _contact = '';
  String _age = '';
  String _gender = '';
  String _email = '';
  bool _isLoading = true;
  bool _emergencyAlertsEnabled = true;
  bool _deviceSyncEnabled = true;

  String _patientCount = '0';

  @override
  void initState() {
    super.initState();
    _fetchDoctorData(widget.username);
  }

  Future<void> _fetchDoctorData(String username) async {
    final apiUrl = '${ip}dprof.php';
    final countUrl = '${ip}dhomecnt.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'username': doctid.isNotEmpty ? doctid : username},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final cleaned = response.body.replaceAll('[', '').replaceAll(']', '').replaceAll("'", '"');
        final values = cleaned.split(',').map((s) => s.trim().replaceAll('"', '')).toList();

        if (values.length >= 5) {
          _name = values[0];
          _contact = values[1];
          _age = values[2];
          _email = values[3];
          _gender = values[4];
        }
      }

      // Fetch live patient count dynamically
      final countRes = await http.post(
        Uri.parse(countUrl),
        body: {'username': doctid.isNotEmpty ? doctid : username},
      ).timeout(const Duration(seconds: 6));
      if (countRes.statusCode == 200 && countRes.body.isNotEmpty) {
        final counts = countRes.body.split(',').map((s) => s.trim()).toList();
        if (counts.isNotEmpty) {
          _patientCount = counts[0].replaceAll(RegExp(r'[^0-9]'), '');
          if (_patientCount.isEmpty) _patientCount = '0';
        }
      }
      // Check admin-provisioned staff details for seamless cross-role sync
      final localDoc = await CrossRoleSyncService().findDoctor(doctid.isNotEmpty ? doctid : username);
      if (localDoc != null) {
        if (_name.isEmpty) _name = localDoc['name'] ?? '';
        if (_contact.isEmpty) _contact = localDoc['contact'] ?? '';
        if (_email.isEmpty) _email = localDoc['email'] ?? '';
        if (_age.isEmpty) _age = localDoc['age'] ?? '';
        if (_gender.isEmpty) _gender = localDoc['gender'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
    }

    if (mounted) {
      setState(() {
        if (_name.isEmpty) _name = doctid.isNotEmpty ? 'Dr. $doctid' : 'Physician';
        if (_contact.isEmpty) _contact = 'Not provided';
        if (_age.isEmpty) _age = '--';
        if (_email.isEmpty) _email = doctid.isNotEmpty ? '$doctid@clinic.com' : 'Not provided';
        if (_gender.isEmpty) _gender = 'Clinician';
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.coralRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.coralRed, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'End Doctor Session',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out of the Clinical Doctor Portal?',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coralRed,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => secondpage()),
                );
              },
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Doctor Profile & Credentials',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.coralRed),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    _buildDoctorHeroCard(),
                    const SizedBox(height: 16),
                    _buildPracticeMetricsCard(),
                    const SizedBox(height: 16),
                    _buildContactCard(),
                    const SizedBox(height: 16),
                    _buildClinicalSettingsCard(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDoctorHeroCard() {
    final displayName = _name.isNotEmpty
        ? (_name.toLowerCase().startsWith('dr') ? _name : 'Dr. $_name')
        : 'Dr. ${widget.username}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.primaryDeepTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    displayName.length > 4 ? displayName.substring(4, 5).toUpperCase() : 'D',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.mintFresh,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryDeepTeal),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pulmonology & Addiction Medicine Specialist',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintFresh.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.4)),
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
                      'CLINICAL ON-DUTY',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  _age.isNotEmpty ? '$_age Yrs • $_gender' : 'REG #TN-MED-84920',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Practice Telemetry',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem(_patientCount, 'Monitored\nPatients', AppColors.primaryTeal),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              _buildStatItem('Active', 'Clinical\nStatus', AppColors.mintFresh),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              _buildStatItem('Live', 'Directive\nBroadcasting', AppColors.primaryDeepTeal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice & Contact Information',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.phone_rounded, 'Phone Number', _contact, AppColors.primaryTeal),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.email_outlined, 'Clinical Email', _email, AppColors.primaryDeepTeal),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.local_hospital_outlined, 'Department', 'Pulmonary & Addiction Medicine', const Color(0xFF0284C7)),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.access_time_rounded, 'Hours', 'Mon - Sat (09:00 AM - 05:00 PM)', const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicalSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Alert Controls',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryTeal,
            title: Text(
              'Relapse Urge Alerts (≥ 7/10)',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            subtitle: Text(
              'Receive immediate push notifications when a patient logs critical craving',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            ),
            value: _emergencyAlertsEnabled,
            onChanged: (val) => setState(() => _emergencyAlertsEnabled = val),
          ),
          const Divider(height: 12, color: Color(0xFFF1F5F9)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryTeal,
            title: Text(
              'Auto-Sync Clinic Spirometer',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            subtitle: Text(
              'Sync digital Bluetooth peak flow telemetry with patient PFT cards',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            ),
            value: _deviceSyncEnabled,
            onChanged: (val) => setState(() => _deviceSyncEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFFEE2E2)),
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout_rounded, color: AppColors.coralRed, size: 18),
        label: Text(
          'Sign Out of Doctor Account',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.coralRed,
          ),
        ),
        onPressed: _showLogoutDialog,
      ),
    );
  }
}
