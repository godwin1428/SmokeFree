import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smokefree/core/session_manager.dart';
import 'package:smokefree/editprofile.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/app_language.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/secondpage.dart';
import 'package:smokefree/theme/app_colors.dart';

class PatProfPage extends StatefulWidget {
  final String username;

  PatProfPage({super.key, String? username}) : username = username ?? userid;

  @override
  _PatProfPageState createState() => _PatProfPageState();
}

class _PatProfPageState extends State<PatProfPage> {
  String name = '';
  String email = '';
  String contact = '';
  String age = '';
  String gender = '';
  Uint8List _imageBytes = Uint8List(0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(widget.username);
  }

  Future<void> fetchData(String username) async {
    final apiUrl = '${ip}prof.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'username': username},
      );

      if (response.statusCode == 200) {
        final values = response.body.split(',');

        if (values.length >= 7) {
          if (!mounted) return;
          setState(() {
            name = values[0].trim().replaceAll(RegExp(r'^[\["]+|[\]"]+$'), '');
            contact = values[1].trim();
            age = values[2].trim();
            email = values[3].trim();
            gender = values[6].trim().replaceAll(RegExp(r'^[\["]+|[\]"]+$'), '');

            try {
              final rawImg = values[4].trim();
              _imageBytes = rawImg.isNotEmpty && rawImg.length > 20
                  ? base64Decode(rawImg)
                  : Uint8List(0);
            } catch (e) {
              _imageBytes = Uint8List(0);
            }

            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }

    if (mounted) {
      setState(() {
        name = user_name.isNotEmpty ? user_name : widget.username;
        contact = user_cont;
        age = user_age;
        email = user_email;
        gender = user_gender;
        _isLoading = false;
      });
    }
  }

  void _openEditProfile() async {
    user_name = name;
    user_cont = contact;
    user_age = age;
    user_email = email;
    user_gender = gender;
    user_dp = _imageBytes.isNotEmpty ? base64Encode(_imageBytes) : '';

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UppldPage()),
    );

    if (mounted) {
      fetchData(widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          isTamil ? 'நோயாளி சுயவிவரம்' : 'Patient Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal),
            tooltip: isTamil ? 'சுயவிவரத்தை திருத்து' : 'Edit Profile',
            onPressed: _openEditProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.coralRed),
            tooltip: isTamil ? 'வெளியேறு' : 'Logout',
            onPressed: () => _showLogoutModal(isTamil),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Profile Header Card
                    _buildProfileHeaderCard(isTamil, patient),
                    const SizedBox(height: 16),

                    // Quick Cessation Stats Row
                    _buildStatsRow(isTamil, patient),
                    const SizedBox(height: 18),

                    // Personal Information Section
                    _buildPersonalInfoCard(isTamil),
                    const SizedBox(height: 18),

                    // App Settings & Preferences Section
                    _buildSettingsCard(isTamil, patient),
                    const SizedBox(height: 24),

                    // Logout Button
                    _buildLogoutButton(isTamil),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(bool isTamil, PatientProvider patient) {
    final displayName = name.isNotEmpty ? name : widget.username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  backgroundImage: _imageBytes.isNotEmpty ? MemoryImage(_imageBytes) : null,
                  child: _imageBytes.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _openEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${widget.username}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  patient.days >= 30
                      ? (isTamil ? '1 மாத நல்வாழ்வு சாதனையாளர்' : '1-Month Cessation Champion')
                      : patient.days >= 7
                          ? (isTamil ? '7 நாள் உறுதிமிகு வீரர்' : '7-Day Resilience Warrior')
                          : (isTamil ? 'புகைப்பிடிக்காத பயணம் • தொடக்க நிலை' : 'Smoke-Free Pioneer'),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isTamil, PatientProvider patient) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.calendar_today_rounded,
            color: AppColors.primaryTeal,
            value: '${patient.days}d',
            label: isTamil ? 'புகைக்காத நாட்கள்' : 'Clean Days',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.savings_rounded,
            color: AppColors.amberGold,
            value: '₹${patient.moneySaved.toStringAsFixed(0)}',
            label: isTamil ? 'சேமித்த பணம்' : 'Money Saved',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.bolt_rounded,
            color: AppColors.mintFresh,
            value: '${patient.points}',
            label: isTamil ? 'சுகாதார புள்ளிகள்' : 'Health Pts',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isTamil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTamil ? 'தனிப்பட்ட விவரங்கள்' : 'Personal Information',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              InkWell(
                onTap: _openEditProfile,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 14, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        isTamil ? 'திருத்து' : 'Edit',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            color: AppColors.primaryTeal,
            label: isTamil ? 'வயது' : 'Age',
            value: age.isNotEmpty ? '$age ${isTamil ? "வயது" : "years old"}' : 'Not set',
          ),
          const Divider(height: 18),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            color: AppColors.skyBlue,
            label: isTamil ? 'பாலினம்' : 'Gender',
            value: gender.isNotEmpty ? gender : 'Not set',
          ),
          const Divider(height: 18),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            color: AppColors.mintFresh,
            label: isTamil ? 'தொலைபேசி' : 'Phone',
            value: contact.isNotEmpty ? contact : 'Not set',
          ),
          const Divider(height: 18),
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            color: AppColors.coralRed,
            label: isTamil ? 'மின்னஞ்சல்' : 'Email',
            value: email.isNotEmpty ? email : 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDeepTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(bool isTamil, PatientProvider patient) {
    final currentLang = AppLanguageCatalog.getLanguageByCode(patient.language);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTamil ? 'அமைப்புகள் & விருப்பத்தேர்வுகள்' : 'Settings & Preferences',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 14),

          // Language Switcher Tile (Interactive 10-Language Selector)
          InkWell(
            onTap: () => _showLanguageSelectionSheet(context, patient),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightCardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.translate_rounded, color: AppColors.primaryTeal, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTamil ? 'பயன்பாட்டு மொழி' : 'App Language',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                        Text(
                          '${currentLang.nativeName} (${currentLang.name})',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentLang.avatarCode,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primaryTeal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),

          // Wishlist Savings Target Tile
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amberGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: AppColors.amberGold, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.wishlistName,
                      style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
                    ),
                    Text(
                      '₹${patient.moneySaved.toStringAsFixed(0)} / ₹${patient.wishlistTarget.toStringAsFixed(0)} (${(patient.wishlistProgress * 100).toStringAsFixed(0)}%)',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.amberGold, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showWishlistModal(isTamil, patient),
                child: Text(
                  isTamil ? 'மாற்று' : 'Edit Goal',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.amberGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: patient.wishlistProgress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amberGold),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionSheet(BuildContext context, PatientProvider patient) {
    final isTamil = patient.isTamil;
    final currentCode = patient.language;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag pill
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.translate_rounded, color: AppColors.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTamil ? 'மொழியைத் தேர்ந்தெடுக்கவும்' : 'Select App Language',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDeepTeal,
                            ),
                          ),
                          Text(
                            isTamil ? '10 பிராந்திய & உலகளாவிய மொழிகள்' : '10 Regional & Global Languages Available',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 10 Languages List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: AppLanguageCatalog.supportedLanguages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = AppLanguageCatalog.supportedLanguages[index];
                    final isSelected = item.code == currentCode;

                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        patient.setLanguage(item.code);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Language set to ${item.nativeName} (${item.name})',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryTeal.withValues(alpha: 0.08)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryTeal : AppColors.lightCardBorder,
                            width: isSelected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar Badge
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.primaryGradient : null,
                                color: isSelected ? null : AppColors.primaryTeal.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.avatarCode,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Language Names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nativeName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? AppColors.primaryDeepTeal : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${item.name} • ${item.region}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selection Indicator
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: Colors.white),
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked_rounded,
                                size: 18,
                                color: Colors.grey.withValues(alpha: 0.4),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(bool isTamil) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppColors.coralRed, size: 18),
        label: Text(
          isTamil ? 'கணக்கிலிருந்து வெளியேறு' : 'Log Out of Account',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.coralRed,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.coralRed, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showLogoutModal(isTamil),
      ),
    );
  }

  void _showWishlistModal(bool isTamil, PatientProvider patient) {
    final nameCtrl = TextEditingController(text: patient.wishlistName);
    final targetCtrl = TextEditingController(text: patient.wishlistTarget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTamil ? 'சேமிப்பு இலக்கை திருத்து' : 'Update Wishlist Savings Target',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryDeepTeal),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isTamil ? 'பொருளின் பெயர்' : 'Item / Dream Target Name',
                  prefixIcon: const Icon(Icons.card_giftcard_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isTamil ? 'இலக்கு தொகை (₹)' : 'Target Cost (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    final newTarget = double.tryParse(targetCtrl.text.trim()) ?? patient.wishlistTarget;
                    if (newName.isNotEmpty) {
                      patient.setWishlist(newName, newTarget);
                    }
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(
                    isTamil ? 'இலக்கை சேமிக்க' : 'Save Savings Target',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutModal(bool isTamil) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.coralRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.coralRed, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  isTamil ? 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?' : 'Confirm Logout?',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil
                      ? 'உங்கள் புகைப்பிடிக்காத நாட்கள் மற்றும் சேமிப்புகள் பாதுகாப்பாக வைக்கப்படும்.'
                      : 'Your streak and health records are safely stored on the server.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          isTamil ? 'ரத்துசெய்' : 'Cancel',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coralRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await SessionManager().clearSession();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => secondpage()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          isTamil ? 'வெளியேறு' : 'Yes, Logout',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
