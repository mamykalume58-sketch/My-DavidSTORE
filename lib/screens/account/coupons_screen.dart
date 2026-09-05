import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/coupon_service.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool _showDisponibles = true;
  final CouponService _couponService = CouponService();

  Color _parseColor(dynamic hex) {
    if (hex == null) return const Color(0xFF2563EB);
    final str = hex.toString().replaceAll('#', '');
    try {
      return Color(int.parse('FF$str', radix: 16));
    } catch (_) {
      return const Color(0xFF2563EB);
    }
  }

  String _formatValidity(dynamic validity) {
    if (validity is Timestamp) {
      final date = validity.toDate();
      return "Valable jusqu'au ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
    return validity?.toString() ?? '';
  }

  String _formatMinOrder(dynamic minOrder) {
    if (minOrder is num) {
      final str = minOrder.toInt().toString();
      final buffer = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
        buffer.write(str[i]);
      }
      return 'Min. $buffer FC';
    }
    return minOrder?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Mes coupons', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showDisponibles = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _showDisponibles ? Theme.of(context).primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _showDisponibles ? Theme.of(context).primaryColor : Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text('Disponibles', style: TextStyle(color: _showDisponibles ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showDisponibles = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_showDisponibles ? Theme.of(context).primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: !_showDisponibles ? Theme.of(context).primaryColor : Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text('Utilisés', style: TextStyle(color: !_showDisponibles ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_showDisponibles
                ? (userId == null
                    ? const Center(child: Text('Connecte-toi pour voir tes coupons utilisés.', style: TextStyle(color: Colors.grey)))
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _couponService.watchUsedCoupons(userId),
                        builder: (context, snapshot) {
                          final used = snapshot.data ?? [];
                          if (used.isEmpty) {
                            return const Center(child: Text('Aucun coupon utilisé pour le moment.', style: TextStyle(color: Colors.grey)));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: used.length,
                            itemBuilder: (context, index) {
                              final c = used[index];
                              final value = c['type'] == 'percent' ? '${c['value']}%' : '${c['value']} FC';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                                child: Row(
                                  children: [
                                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(c['code']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _couponService.watchAvailableCoupons(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final coupons = snapshot.data ?? [];
                      if (coupons.isEmpty) {
                        return const Center(child: Text('Aucun coupon disponible pour le moment.', style: TextStyle(color: Colors.grey)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          final c = coupons[index];
                          final color = _parseColor(c['color']);
                          final value = c['type'] == 'percent' ? '${c['value']}%' : '${c['value']} FC';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                                    const Text('DE RÉDUCTION', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c['code']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text(_formatValidity(c['validity']), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text(_formatMinOrder(c['minOrder']), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
