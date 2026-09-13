import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/device_service.dart';

class ConnectedDevicesScreen extends StatelessWidget {
  const ConnectedDevicesScreen({super.key});

  IconData _iconForPlatform(String platform) {
    switch (platform) {
      case 'Android':
        return Icons.phone_android;
      case 'iOS':
        return Icons.phone_iphone;
      default:
        return Icons.devices_other;
    }
  }

  String _formatLastActive(Timestamp? timestamp) {
    if (timestamp == null) return 'À l\'instant';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Actif maintenant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Il y a 1 jour';
    return 'Il y a ${diff.inDays} jours';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Appareils connectés',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DeviceService().watchDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Aucun appareil connecté', style: TextStyle(color: Color(0xFF64748B))),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = data['name'] as String? ?? 'Appareil inconnu';
              final platform = data['platform'] as String? ?? 'Autre';
              final lastActive = data['lastActive'] as Timestamp?;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Icon(_iconForPlatform(platform), color: const Color(0xFF1E3A8A)),
                  title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '$platform · ${_formatLastActive(lastActive)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
