import 'package:flutter/material.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Sessions actives', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Session actuelle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('Ce téléphone · Connecté maintenant', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ),
          ),
        ],
      ),
    );
  }
}
