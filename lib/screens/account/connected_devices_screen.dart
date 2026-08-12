import 'package:flutter/material.dart';

class ConnectedDevicesScreen extends StatelessWidget {
  const ConnectedDevicesScreen({super.key});

  static const List<Map<String, String>> _devices = [
    {'name': 'Cet appareil', 'detail': 'Android · Session actuelle'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Appareils connectés', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _devices.map((d) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.smartphone_outlined, color: Color(0xFF64748B)),
              title: Text(d['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(d['detail']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ),
          );
        }).toList(),
      ),
    );
  }
}
