import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afya_clinic/config/app_theme.dart';
import 'package:afya_clinic/features/splash/widgets/plus_buddy_painter.dart';

void main() {
  testWidgets('App branding and logo render successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          backgroundColor: AppTheme.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlusBuddyLogo(size: 120),
                SizedBox(height: 24),
                Text(
                  'Afya Clinic',
                  style: TextStyle(
                    color: AppTheme.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Afya Clinic'), findsOneWidget);
    expect(find.byType(PlusBuddyLogo), findsOneWidget);
  });
}
