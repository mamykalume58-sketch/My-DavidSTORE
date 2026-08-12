import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'fr';

  final List<Map<String, String>> _languages = const [
    {'code': 'fr', 'label': 'Français'},
    {'code': 'en', 'label': 'Anglais'},
    {'code': 'ln', 'label': 'Lingala'},
    {'code': 'sw', 'label': 'Swahili'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Langue', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _languages.map((lang) {
          final isAvailable = lang['code'] == 'fr';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: RadioListTile<String>(
              value: lang['code']!,
              groupValue: _selected,
              onChanged: isAvailable
                  ? (v) => setState(() => _selected = v!)
                  : null,
              activeColor: theme.primaryColor,
              title: Text(lang['label']!, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
              subtitle: isAvailable
                  ? null
                  : const Text('Bientôt disponible', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ),
          );
        }).toList(),
      ),
    );
  }
}
