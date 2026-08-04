import 'package:flutter/material.dart';

import '../../services/session_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final String imagePath;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Bienvenue sur DavidSTORE',
      subtitle: 'Le shopping intelligent commence, ici.',
      imagePath: 'assets/images/onboarding/onboarding_1.png',
    ),
    _OnboardingPageData(
      title: 'Large choix de produits',
      subtitle: "Découvrez des milliers d'articles de qualité.",
      imagePath: 'assets/images/onboarding/onboarding_2.png',
    ),
    _OnboardingPageData(
      title: 'Paiement facile et sécurisé',
      subtitle: 'Payez avec M-Pesa, Airtel Money ou Orange Money.',
      imagePath: 'assets/images/onboarding/onboarding_3.png',
    ),
    _OnboardingPageData(
      title: 'Livraison rapide et fiable',
      subtitle: 'Nous livrons vos commandes partout en RDC.',
      imagePath: 'assets/images/onboarding/onboarding_4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await SessionService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Passer',
                  style: TextStyle(color: Color(0xFFFF6B35)),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: Image.asset(
                              page.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0A1030),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFFFF6B35)
                        : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _onNextPressed,
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
