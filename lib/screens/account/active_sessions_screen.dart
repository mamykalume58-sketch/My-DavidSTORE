import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/device_service.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final _deviceService = DeviceService();
  String? _currentDeviceId;

  @override
  void initState() {
    super.initState();
    _deviceService.currentDeviceId().then((id) {
      if (mounted) setState(() => _currentDeviceId = id);
    });
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

  Future<void> _closeSession(String deviceId) async {
    await _deviceService.removeDevice(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Sessions actives',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _deviceService.watchDevices(),
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
              child: Text('Aucune session active', style: TextStyle(color: Color(0xFF64748B))),
            );
          }

          final current = docs.where((d) => d.id == _currentDeviceId).toList();
          final others = docs.where((d) => d.id != _currentDeviceId).toList();
          final ordered = [...current, ...others];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = ordered[index];
              final data = doc.data();
              final isCurrent = doc.id == _currentDeviceId;
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
                  leading: Icon(
                    isCurrent ? Icons.check_circle : Icons.devices_other,
                    color: isCurrent ? Colors.green : const Color(0xFF64748B),
                  ),
                  title: Text(
                    isCurrent ? 'Session actuelle' : name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isCurrent
                        ? '$name · Actif maintenant'
                        : '$platform · ${_formatLastActive(lastActive)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  trailing: isCurrent
                      ? null
                      : TextButton(
                          onPressed: () => _closeSession(doc.id),
                          child: const Text('Fermer', style: TextStyle(color: Colors.red)),
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
