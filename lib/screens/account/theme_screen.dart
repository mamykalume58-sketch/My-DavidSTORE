import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selected = 'clair';

  final List<Map<String, dynamic>> _options = const [
    {'code': 'clair', 'label': 'Clair', 'icon': Icons.light_mode_outlined},
    {'code': 'sombre', 'label': 'Sombre', 'icon': Icons.dark_mode_outlined},
    {'code': 'systeme', 'label': 'Automatique (système)', 'icon': Icons.brightness_auto_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Thème', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _options.map((opt) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: RadioListTile<String>(
              value: opt['code'] as String,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              activeColor: theme.primaryColor,
              secondary: Icon(opt['icon'] as IconData, color: const Color(0xFF64748B)),
              title: Text(opt['label'] as String, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
            ),
          );
        }).toList(),
      ),
    );
  }
}
