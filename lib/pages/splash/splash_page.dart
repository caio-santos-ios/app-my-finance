import 'package:finance/core/services/auth_service.dart';
import 'package:finance/pages/main/main_page.dart';
import 'package:finance/pages/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _onInit();
  }

  Future<void> _onInit() async {
    await Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) {
        String token = AuthService.getToken();

        if (token.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingPage()),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage(initialPage: 0)),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(child: Center(child: _buildLogo())),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/logo-secondary.png"),
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }
}
