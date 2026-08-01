import 'package:flutter/material.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Inscription
  final _nomController = TextEditingController();
  final _emailInscriptionController = TextEditingController();
  final _mdpInscriptionController = TextEditingController();
  final _confirmMdpController = TextEditingController();

  // Connexion
  final _emailConnexionController = TextEditingController();
  final _mdpConnexionController = TextEditingController();

  bool _mdpInscriptionVisible = false;
  bool _confirmMdpVisible = false;
  bool _mdpConnexionVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomController.dispose();
    _emailInscriptionController.dispose();
    _mdpInscriptionController.dispose();
    _confirmMdpController.dispose();
    _emailConnexionController.dispose();
    _mdpConnexionController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? passwordVisible,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E5A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !(passwordVisible ?? false),
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B00)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (passwordVisible ?? false)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white38,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInscriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nomController,
            hint: 'Nom complet',
            icon: Icons.person_outline,
          ),
          _buildTextField(
            controller: _emailInscriptionController,
            hint: 'Adresse e-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            controller: _mdpInscriptionController,
            hint: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            passwordVisible: _mdpInscriptionVisible,
            onToggleVisibility: () {
              setState(() {
                _mdpInscriptionVisible = !_mdpInscriptionVisible;
              });
            },
          ),
          _buildTextField(
            controller: _confirmMdpController,
            hint: 'Confirmer le mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            passwordVisible: _confirmMdpVisible,
            onToggleVisibility: () {
              setState(() {
                _confirmMdpVisible = !_confirmMdpVisible;
              });
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _tabController.animateTo(1);
            },
            child: const Text(
              'Déjà un compte ? Se connecter',
              style: TextStyle(color: Color(0xFFFF6B00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnexionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailConnexionController,
            hint: 'Adresse e-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            controller: _mdpConnexionController,
            hint: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
            passwordVisible: _mdpConnexionVisible,
            onToggleVisibility: () {
              setState(() {
                _mdpConnexionVisible = !_mdpConnexionVisible;
              });
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            child: const Text(
              "Pas encore de compte ? S'inscrire",
              style: TextStyle(color: Color(0xFFFF6B00)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Image.asset('assets/images/logo.png', height: 80),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E5A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFFF6B00),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "S'inscrire"),
                  Tab(text: 'Se connecter'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInscriptionTab(),
                  _buildConnexionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
