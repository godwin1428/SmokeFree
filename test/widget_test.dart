import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smokefree/main.dart';
import 'package:smokefree/providers/patient_provider.dart';

void main() {
  testWidgets('SmokeFree app loads onboarding page test', (WidgetTester tester) async {
    final provider = PatientProvider(autoStartTicker: false);
    await tester.pumpWidget(
      ChangeNotifierProvider<PatientProvider>.value(
        value: provider,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the Get Started button exists
    expect(find.text('Get Started'), findsOneWidget);

    provider.dispose();
  });
}
