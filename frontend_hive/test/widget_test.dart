import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_hive/app/afya_hive_app.dart';

void main() {
  testWidgets('shows the AfyaHive sign-in experience', (tester) async {
    await tester.pumpWidget(const AfyaHiveApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Your health,\nall in one place.'), findsOneWidget);
    expect(find.text('Secure Sign In'), findsOneWidget);
  });
}
