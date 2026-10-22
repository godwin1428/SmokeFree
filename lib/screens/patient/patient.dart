import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smokefree/motivation.dart';
import 'package:smokefree/patprof.dart';
import 'package:smokefree/screens/cravings/craving_sos_screen.dart';
import 'package:smokefree/screens/patient/modern_patient_dashboard.dart';
import 'package:smokefree/theme/app_colors.dart';

class Patient extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<Patient> {
  int _currentIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const ModernPatientDashboard();
      case 1:
        return const CravingSosScreen();
      case 2:
        return const Motivation();
      case 3:
        return PatProfPage();
      default:
        return const ModernPatientDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _getPage(_currentIndex),
        bottomNavigationBar: _buildModernBottomNav(),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    final items = [
      {'icon': Icons.space_dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.shield_rounded, 'label': 'SOS Craving'},
      {'icon': Icons.psychology_rounded, 'label': 'Motivation'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryTeal.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isSelected ? AppColors.primaryTeal : AppColors.textSubtle,
                        size: 24,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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

// Placeholder Widgets for the other pages
class PatientHomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Patient Home Page Content'));
  }
}

class PatientHealthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Patient Health Page'));
  }
}

class PatientMoneyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Patient Money Page'));
  }
}

class PatientProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Patient Profile Page'));
  }
}
