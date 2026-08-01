import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _goNext() {
    if (_currentPage < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // La logique du 3ᵉ écran (Commencer / Se connecter) sera ajoutée
    // une fois cet écran construit.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildSlideOne(),
              _buildSlideTwo(),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Row(
                  children: List.generate(2, (index) {
                    final bool active = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? (_currentPage == 0 ? AppColors.white : AppColors.orangeDark)
                            : (_currentPage == 0 ? AppColors.whiteMuted : AppColors.textGrey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentPage == 0 ? AppColors.white : AppColors.orangeDark,
                    foregroundColor:
                        _currentPage == 0 ? AppColors.orangeDark : AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Suivant'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideOne() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/onboarding1.png', fit: BoxFit.cover),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag,
                          color: AppColors.orangeDark, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'DavidSTORE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Le shopping intelligent\ncommence, ici.',
                  style: AppTextStyles.onboardingTitle,
                ),
                const SizedBox(height: 16),
                Container(width: 40, height: 2, color: AppColors.white),
                const SizedBox(height: 16),
                const Text(
                  'Des milliers de produits pour\ndévelopper votre activité.',
                  style: AppTextStyles.onboardingSubtitle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideTwo() {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Image.asset(
            'assets/images/onboarding2.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.orangeDark,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.shopping_cart,
                      color: AppColors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sélections tendance\nprêtes à être expédiées',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Les meilleurs produits, livrés rapidement.',
                        style: AppTextStyles.cardBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
