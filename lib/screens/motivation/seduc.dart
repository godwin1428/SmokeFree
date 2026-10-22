import 'package:flutter/material.dart';
import 'package:smokefree/models/daily_checkin_result.dart';
import 'package:smokefree/screens/motivation/motivation_pillar_detail_screen.dart';

class Seduc extends StatelessWidget {
  const Seduc({super.key});

  @override
  Widget build(BuildContext context) {
    return const MotivationPillarDetailScreen(
      pillar: MotivationPillar.seduction,
    );
  }
}
