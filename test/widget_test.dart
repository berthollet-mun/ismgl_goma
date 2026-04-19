import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ismgl/app/initialization.dart';
import 'package:ismgl/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    await AppInitialization.initialize();
  });

  tearDownAll(Get.reset);

  testWidgets('ISMGL app démarre (splash puis navigation)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('ISMGL'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('ISMGL'), findsWidgets);
  });
}
