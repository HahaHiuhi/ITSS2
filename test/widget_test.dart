import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:student_academic_planner/main.dart';
import 'package:student_academic_planner/services/supabase_service.dart';

void main() {
  testWidgets('App renders auth screen and enters demo mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SupabaseService(),
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue demo'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue demo'));
    await tester.tap(find.text('Continue demo'));
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Subjects'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(find.text('Student information'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await tester.pump();

    expect(find.text('Preferences'), findsOneWidget);
  });
}
