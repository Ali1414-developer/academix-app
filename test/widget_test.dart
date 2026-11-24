import 'package:academix/app/app.dart';
import 'package:academix/core/state/academix_provider.dart';
import 'package:academix/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AcademiX boots splash screen, onboarding, and welcome flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcademiXApp());

    expect(find.text('AcademiX'), findsOneWidget);
    expect(find.text('AI-Powered Academic Platform'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen (Frame 00:04)
    expect(find.text('AI-Powered Grading'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Skip to transition to Welcome Gateway Screen (Frame 00:08)
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);
    expect(find.text('Teacher Portal'), findsOneWidget);
  });

  testWidgets('Quick demo login opens Student Portal with 5 bottom nav tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcademiXApp());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    // Skip onboarding to welcome gateway
    final skipFinder = find.text('Skip');
    if (skipFinder.evaluate().isNotEmpty) {
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();
    }

    final studentPortalFinder = find.text('Student Portal');
    await tester.ensureVisible(studentPortalFinder);
    await tester.tap(studentPortalFinder);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Class Management test: class code validation and student enrollment',
      (WidgetTester tester) async {
    final provider = AcademiXProvider();
    provider.quickLogin(UserRole.teacher);

    // 1. Teacher creates a class
    final newClass = provider.createClass(
      name: 'Mobile App Development - Sec A',
      subject: 'Mobile Applications',
      courseCode: 'CS-415',
      section: 'Sec A',
    );
    expect(newClass.classCode.startsWith('CS-'), isTrue);
    expect(provider.getTeacherClasses().any((c) => c.id == newClass.id), isTrue);

    // 2. Student joins via code
    provider.quickLogin(UserRole.student);
    final joinErr = provider.joinClass(newClass.classCode);
    expect(joinErr, isNull);

    // 3. Prevent duplicate enrollment
    final dupErr = provider.joinClass(newClass.classCode);
    expect(dupErr, contains('already enrolled'));

    // 4. Invalid code returns error
    final invalidErr = provider.joinClass('INVALID-999');
    expect(invalidErr, contains('Invalid class code'));

    // 5. Enrolled student sees the class
    final enrolledClasses = provider.getStudentClasses();
    expect(enrolledClasses.any((c) => c.id == newClass.id), isTrue);
  });
}
