import 'package:flutter/material.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool _showDisponibles = true;

  final List<Map<String, dynamic>> _coupons = const [
    {'percent': '10%', 'code': 'BIENVENUE10', 'validity': 'Valable jusqu\'au 31/12/2026', 'minOrder': 'Min. 50.000 FC', 'color': Color(0xFFF59E0B)},
    {'amount': '5.000 FC', 'code': 'DAVIDS000', 'validity': 'Valable jusqu\'au 25/12/2026', 'minOrder': 'Min. 30.000 FC', 'color': Color(0xFF2563EB)},
    {'percent': '15%', 'code': 'FEST15', 'validity': 'Valable jusqu\'au 20/11/2026', 'minOrder': 'Min. 70.000 FC', 'color': Color(0xFF16A34A)},
  ];

  @override
  Widget build(BuildContext context) {
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
                ? const Center(child: Text('Aucun coupon utilisé pour le moment.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _coupons.length,
                    itemBuilder: (context, index) {
                      final c = _coupons[index];
                      final Color color = c['color'] as Color;
                      final String value = c['percent'] ?? c['amount'] ?? '';

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
                                  Text(c['code'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(c['validity'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  Text(c['minOrder'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
