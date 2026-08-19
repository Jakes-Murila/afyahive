import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_hive/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('shows the AfyaHive sign-in experience', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Your health,\nall in one place.'), findsOneWidget);
    expect(find.text('Secure Sign In'), findsOneWidget);
  });
}
