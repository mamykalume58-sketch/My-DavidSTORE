import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _goNext() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _goToRegister() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
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
              _buildSlideThree(),
            ],
          ),
          if (_currentPage < 2)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  Row(
                    children: List.generate(3, (index) {
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

  Widget _buildSlideThree() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/onboarding3.png', fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0.35, 0.75],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
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
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'DAVID',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: 'STORE',
                            style: TextStyle(
                              color: AppColors.orangeDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Le shopping intelligent\ncommence, ici.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCheckItem('Plus de 200 millions de produits'),
                const SizedBox(height: 10),
                _buildCheckItem('Produits disponibles et personnalisables'),
                const SizedBox(height: 10),
                _buildCheckItem(
                    'Commandez et recevez vos colis en toute sécurité partout en RDC'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDark,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Commencer',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'S\'inscrire ou se connecter',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.orangeDark, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
