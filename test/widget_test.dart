import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:appantibloqueo/app/presentation/pages/splash_page.dart';

void main() {
  testWidgets('Splash page renders and completes timer',
      (WidgetTester tester) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashPage(onFinished: () => finished = true),
      ),
    );
    expect(find.byType(SplashPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(finished, isTrue);
  });
}
