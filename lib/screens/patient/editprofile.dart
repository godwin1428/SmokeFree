import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/core/session_manager.dart';
import 'package:smokefree/ip.dart';
import 'package:smokefree/models/app_language.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_colors.dart';

class UppldPage extends StatefulWidget {
  final String? name = user_name;
  final String? age = user_age;
  final String? gender = user_gender;
  final String? contact = user_cont;
  final String? email = user_email;
  final String? base64Image = user_dp;

  UppldPage({super.key});

  @override
  _UppldPageState createState() => _UppldPageState();
}

class _UppldPageState extends State<UppldPage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController contactController;
  late TextEditingController emailController;
  String selectedGender = 'Male';
  late String selectedLanguageCode;
  late String selectedLanguage;
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name ?? '');
    ageController = TextEditingController(text: widget.age ?? '');
    contactController = TextEditingController(text: widget.contact ?? '');
    emailController = TextEditingController(text: widget.email ?? '');

    final initialGender = (widget.gender ?? 'Male').trim();
    if (_genders.contains(initialGender)) {
      selectedGender = initialGender;
    } else if (initialGender.toLowerCase().startsWith('f')) {
      selectedGender = 'Female';
    } else {
      selectedGender = 'Male';
    }

    selectedLanguageCode = lang.isNotEmpty ? lang : '2';
    selectedLanguage = AppLanguageCatalog.getLanguageByCode(selectedLanguageCode).name;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    contactController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  String? _encodeImageToBase64() {
    if (selectedImage != null) {
      final bytes = File(selectedImage!.path).readAsBytesSync();
      return base64Encode(bytes);
    }
    return widget.base64Image;
  }

  Future<void> _handleSave() async {
    final String name = nameController.text.trim();
    final String age = ageController.text.trim();
    final String gender = selectedGender;
    final String contact = contactController.text.trim();
    final String email = emailController.text.trim();
    final String languageCode = selectedLanguageCode;
    final String? base64Image = _encodeImageToBase64();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      // 1. Upload profile image if present
      if (base64Image != null && base64Image.isNotEmpty) {
        await _uploadProfileImage(base64Image);
        user_dp = base64Image;
      }

      // 2. Upload other details
      await _uploadUserDetails(name, age, gender, contact, email, languageCode);

      // 3. Sync local state
      user_name = name;
      user_age = age;
      user_gender = gender;
      user_cont = contact;
      user_email = email;
      lang = languageCode;

      // Update provider
      if (mounted) {
        final provider = Provider.of<PatientProvider>(context, listen: false);
        provider.setLanguage(languageCode);

        // Update persistent session
        await SessionManager().saveUserSession(
          username: userid,
          role: 'patient',
          lang: languageCode,
          name: name,
          email: email,
          contact: contact,
          age: age,
          gender: gender,
          points: user_pnts,
          moneySaved: user_monsav,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              selectedLanguage == 'தமிழ்'
                  ? 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!'
                  : 'Profile updated successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.coralRed,
            content: Text('Error saving profile: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadProfileImage(String base64Image) async {
    final Uri imageApiUrl = Uri.parse('${ip}img_upld.php');
    final Map<String, String> data = {
      'username': userid,
      'image': base64Image,
    };

    try {
      await http.post(
        imageApiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Profile image upload error: $e');
    }
  }

  Future<void> _uploadUserDetails(
    String name,
    String age,
    String gender,
    String contact,
    String email,
    String language,
  ) async {
    final Uri detailsApiUrl = Uri.parse('${ip}edit.php');
    final Map<String, String> data = {
      'username': userid,
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'email': email,
      'lang': language,
    };

    try {
      await http.post(
        detailsApiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('User details upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = selectedLanguage == 'தமிழ்';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryDeepTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'சுயவிவரம் திருத்துதல்' : 'Edit Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Picker Card
              _buildAvatarPicker(isTamil),
              const SizedBox(height: 24),

              // Form Inputs Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                      isTamil ? 'அடிப்படை விவரங்கள்' : 'Account Information',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    _buildInputField(
                      controller: nameController,
                      label: isTamil ? 'முழு பெயர்' : 'Full Name',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 14),

                    // Age Field
                    _buildInputField(
                      controller: ageController,
                      label: isTamil ? 'வயது' : 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    // Gender Selector
                    Text(
                      isTamil ? 'பாலினம்:' : 'Gender:',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _genders.map((g) {
                        final isSelected = selectedGender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedGender = g);
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryTeal : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryTeal : AppColors.lightCardBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                g,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Contact Field
                    _buildInputField(
                      controller: contactController,
                      label: isTamil ? 'தொலைபேசி எண்' : 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    // Email Field
                    _buildInputField(
                      controller: emailController,
                      label: isTamil ? 'மின்னஞ்சல் முகவரி' : 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Language Selection Card (10 Languages Modal Picker)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.translate_rounded, color: AppColors.primaryTeal, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'பயன்பாட்டு மொழி விருப்பம்' : 'App Language Preference',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _showLanguagePicker(context),
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
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                AppLanguageCatalog.getLanguageByCode(selectedLanguageCode).avatarCode,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLanguageCatalog.getLanguageByCode(selectedLanguageCode).nativeName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDeepTeal,
                                    ),
                                  ),
                                  Text(
                                    '${AppLanguageCatalog.getLanguageByCode(selectedLanguageCode).name} • ${AppLanguageCatalog.getLanguageByCode(selectedLanguageCode).region}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
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
                                    isTamil ? 'மாற்று' : 'Change',
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
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    _isSaving
                        ? (isTamil ? 'சேமிக்கப்படுகிறது...' : 'Saving Changes...')
                        : (isTamil ? 'மாற்றங்களை சேமிக்கவும்' : 'Save Changes'),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(bool isTamil) {
    ImageProvider? imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(File(selectedImage!.path));
    } else if (widget.base64Image != null && widget.base64Image!.isNotEmpty && widget.base64Image!.length > 20) {
      try {
        imageProvider = MemoryImage(base64Decode(widget.base64Image!));
      } catch (_) {
        imageProvider = null;
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person, size: 52, color: AppColors.textMuted)
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.amberGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.primaryTeal),
          label: Text(
            isTamil ? 'படத்தை மாற்ற தொடவும்' : 'Change Profile Picture',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.primaryTeal, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final isTamil = selectedLanguageCode == '1';

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
                    final isSelected = item.code == selectedLanguageCode;

                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          selectedLanguageCode = item.code;
                          selectedLanguage = item.name;
                        });
                        Navigator.pop(ctx);
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
}
