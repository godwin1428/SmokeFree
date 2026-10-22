import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/core/session_manager.dart';
import 'package:smokefree/firstpage.dart';
import 'package:smokefree/providers/patient_provider.dart';
import 'package:smokefree/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().loadSavedSession();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Custom scroll behavior that suppresses all desktop/web scrollbars
/// while enabling smooth touch, mouse, and trackpad dragging.
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Suppress intrusive desktop/web scrollbars entirely
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);

    return MaterialApp(
      title: 'SmokeFree',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoScrollbarBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: patient.themeMode,
      home: firstpage(),
    );
  }
}
