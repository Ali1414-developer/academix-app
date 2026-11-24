import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/state/academix_provider.dart';
import '../features/authentication/screens/auth_screens.dart';
import '../features/student/student_shell.dart';
import '../features/teacher/teacher_shell.dart';
import '../models/user_model.dart';
import 'theme.dart';

enum _AuthView {
  splash,
  onboarding,
  welcome,
  login,
  studentRegister,
  teacherRegister,
  forgotPassword,
  resetPassword,
}

class AcademiXApp extends StatelessWidget {
  const AcademiXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AcademiXProvider(),
      child: MaterialApp(
        title: 'AcademiX – AI-Powered Teaching Assistant',
        debugShowCheckedModeBanner: false,
        theme: AcademiXTheme.lightTheme,
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  _AuthView _authView = _AuthView.splash;
  String _resetEmail = 'ayesha.khan@academix.edu';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AcademiXProvider>().currentUser;

    if (user != null) {
      return user.role == UserRole.student
          ? const StudentShell()
          : const TeacherShell();
    }

    Widget screen;
    switch (_authView) {
      case _AuthView.splash:
        screen = SplashScreen(
          onComplete: () => setState(() => _authView = _AuthView.onboarding),
        );
        break;
      case _AuthView.onboarding:
        screen = OnboardingScreen(
          onComplete: () => setState(() => _authView = _AuthView.welcome),
        );
        break;
      case _AuthView.welcome:
        screen = WelcomeScreen(
          onGoLogin: () => setState(() => _authView = _AuthView.login),
          onGoStudentRegister: () =>
              setState(() => _authView = _AuthView.studentRegister),
          onGoTeacherRegister: () =>
              setState(() => _authView = _AuthView.teacherRegister),
        );
        break;
      case _AuthView.login:
        screen = LoginScreen(
          onBack: () => setState(() => _authView = _AuthView.welcome),
          onForgotPassword: () =>
              setState(() => _authView = _AuthView.forgotPassword),
          onGoStudentRegister: () =>
              setState(() => _authView = _AuthView.studentRegister),
          onGoTeacherRegister: () =>
              setState(() => _authView = _AuthView.teacherRegister),
        );
        break;
      case _AuthView.studentRegister:
        screen = RegistrationScreen(
          role: UserRole.student,
          onBack: () => setState(() => _authView = _AuthView.welcome),
          onGoLogin: () => setState(() => _authView = _AuthView.login),
        );
        break;
      case _AuthView.teacherRegister:
        screen = RegistrationScreen(
          role: UserRole.teacher,
          onBack: () => setState(() => _authView = _AuthView.welcome),
          onGoLogin: () => setState(() => _authView = _AuthView.login),
        );
        break;
      case _AuthView.forgotPassword:
        screen = ForgotPasswordScreen(
          onBack: () => setState(() => _authView = _AuthView.login),
          onCodeSent: (email) {
            setState(() {
              _resetEmail = email;
              _authView = _AuthView.resetPassword;
            });
          },
        );
        break;
      case _AuthView.resetPassword:
        screen = ResetPasswordScreen(
          email: _resetEmail,
          onBack: () => setState(() => _authView = _AuthView.forgotPassword),
          onResetComplete: () => setState(() => _authView = _AuthView.login),
        );
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey(_authView),
        child: screen,
      ),
    );
  }
}
