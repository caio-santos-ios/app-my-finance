import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/core/widgets/primary_button.dart';
import 'package:finance/core/widgets/secondary_button.dart';
import 'package:finance/pages/auth/login_page.dart';
import 'package:finance/pages/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();

  final _titles = [
    "Tenha controle total do seu dinheiro",
    "Saiba para onde vai o seu dinheiro",
    "Planejamento antecipado",
  ];
  final _subtitles = [
    "Torne-se o gestor do seu próprio dinheiro e faça cada centavo valer a pena.",
    "Acompanhe suas transações facilmente, com categorias e relatório financeiro.",
    "Defina seu orçamento para cada categoria para manter o controle.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildPageView(),
              PrimaryButton(
                isLoading: false,
                text: "Inscrever-se",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
              ),
              SizedBox(height: 16),
              SecondaryButton(
                isLoading: false,
                text: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView.builder(
        controller: controller,
        itemCount: _titles.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(child: _onboardingImage(index + 1)),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _onboardingTitle(_titles[index]),
                    const SizedBox(height: 8),
                    _onboardingSubtitle(_subtitles[index]),
                    const SizedBox(height: 20),
                    SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: SlideEffect(
                        spacing: 18,
                        dotHeight: 16.0,
                        paintStyle: PaintingStyle.stroke,
                        strokeWidth: 1.5,
                        dotColor: AppColors.violet20,
                        activeDotColor: Theme.of(context).colorScheme.primary,
                      ),
                      onDotClicked: (index) {
                        controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _onboardingImage(int index) {
    return Image.asset("assets/images/onboarding-$index.png", height: 300);
  }

  Widget _onboardingTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _onboardingSubtitle(String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        subtitle,
        style: GoogleFonts.inter(color: Color(0xFF91919F), fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
