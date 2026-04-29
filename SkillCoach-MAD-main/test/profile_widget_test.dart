import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillcoach_mad/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:skillcoach_mad/features/profile/presentation/widgets/profile_stats_widget.dart';

void main() {
  group('Profile Widget Tests', () {
    testWidgets('ProfileHeaderWidget displays name and email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              name: 'John Doe',
              email: 'john@example.com',
              avatarUrl: '',
            ),
          ),
        ),
      );

      expect(find.text('JOHN DOE'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('ProfileStatsWidget displays hours and courses', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsWidget(
              hoursLearned: 45,
              coursesCompleted: 12,
            ),
          ),
        ),
      );

      expect(find.text('45'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });
  });
}
