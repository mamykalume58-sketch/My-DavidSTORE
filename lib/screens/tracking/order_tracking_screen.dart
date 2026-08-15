import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';
import '../../utils/price_formatter.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  static const List<Map<String, dynamic>> _flow = [
    {'key': 'pending', 'title': 'Commande confirmée', 'desc': 'Ta commande a été confirmée.', 'icon': Icons.shopping_cart},
    {'key': 'preparing', 'title': 'Préparation en cours', 'desc': 'Ta commande est en cours de préparation.', 'icon': Icons.inventory_2},
    {'key': 'shipped', 'title': 'Expédiée', 'desc': 'Ta commande a été expédiée.', 'icon': Icons.local_shipping},
    {'key': 'in_transit', 'title': 'En transit', 'desc': 'Ta commande est en route vers ton adresse.', 'icon': Icons.location_on},
    {'key': 'out_for_delivery', 'title': 'En livraison', 'desc': 'Le livreur est en route.', 'icon': Icons.moped},
    {'key': 'delivered', 'title': 'Livrée', 'desc': 'Ta commande a été livrée avec succès.', 'icon': Icons.check_circle},
  ];

  static const List<String> _order = ['pending', 'preparing', 'shipped', 'in_transit', 'out_for_delivery', 'delivered'];

  Map<String, dynamic> _statusBadge(String status) {
    switch (status) {
      case 'delivered':
        return {'label': 'Livrée', 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFDCFCE7)};
      case 'cancelled':
        return {'label': 'Annulée', 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEE2E2)};
      case 'shipped':
      case 'in_transit':
      case 'out_for_delivery':
        return {'label': 'Expédiée', 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFDBEAFE)};
      default:
        return {'label': 'Confirmée', 'color': const Color(0xFFC2410C), 'bg': const Color(0xFFFFEDD5)};
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    const mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${mois[date.month - 1]} ${date.year} à $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedId = orderId ?? (ModalRoute.of(context)?.settings.arguments as String?);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.navyDark),
                  ),
                  const Expanded(
                    child: Text(
                      'Détails de la commande',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: resolvedId == null
                  ? const Center(child: Text('Commande introuvable.'))
                  : StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders').doc(resolvedId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('Commande introuvable.'));
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        data['id'] = snapshot.data!.id;
                        final order = OrderModel.fromMap(data);
                        final badge = _statusBadge(order.status);
                        final currentIndex = _order.indexOf(order.status);
                        final isCancelled = order.status == 'cancelled';

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // En-tête commande
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text('Commande #${order.orderNumber}',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: badge['bg'] as Color,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(badge['label'] as String,
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: badge['color'] as Color)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatDateTime(order.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                    const Divider(height: 28),
                                    ...order.items.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                                clipBehavior: Clip.antiAlias,
                                                alignment: Alignment.center,
                                                child: item.image.isNotEmpty
                                                    ? Image.memory(
                                                        base64Decode(item.image.contains(',')
                                                            ? item.image.split(',').last
                                                            : item.image),
                                                        width: 56,
                                                        height: 56,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) =>
                                                            const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                                                      )
                                                    : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                                    const SizedBox(height: 2),
                                                    if (item.color.isNotEmpty)
                                                      Text(item.color, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                                    Text('Quantité : ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                                  ],
                                                ),
                                              ),
                                              Text(formatPrice(item.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                                            ],
                                          ),
                                        )),
                                    const Divider(height: 8),
                                    const SizedBox(height: 12),
                                    _totalRow('Sous-total', formatPrice(order.sousTotal)),
                                    const SizedBox(height: 6),
                                    _totalRow('Livraison', formatPrice(order.fraisLivraison)),
                                    const SizedBox(height: 10),
                                    _totalRow('Total payé', formatPrice(order.total), bold: true, color: const Color(0xFF16A34A)),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Suivi de commande
                              if (!isCancelled)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(10)),
                                            child: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 20),
                                          ),
                                          const SizedBox(width: 10),
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Suivi de commande', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                              Text('Suivez votre commande en temps réel', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ...List.generate(_flow.length, (index) {
                                        final step = _flow[index];
                                        final done = currentIndex >= 0 && index <= currentIndex;
                                        final isLast = index == _flow.length - 1;
                                        final isFinal = step['key'] == 'delivered' && done;
                                        return IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: !done ? Colors.grey.shade300 : (isFinal ? const Color(0xFF16A34A) : const Color(0xFF2563EB)),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Icon(done ? Icons.check : step['icon'] as IconData, color: Colors.white, size: 16),
                                                  ),
                                                  if (!isLast)
                                                    Expanded(
                                                      child: Container(width: 2, color: done ? const Color(0xFF2563EB) : Colors.grey.shade300),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(bottom: 22),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(step['title'] as String,
                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: done ? AppColors.navyDark : Colors.grey.shade400)),
                                                      const SizedBox(height: 2),
                                                      Text(done ? (step['desc'] as String) : '',
                                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Infos de livraison
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 20),
                                        SizedBox(width: 8),
                                        Text('Informations de livraison', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text('Adresse de livraison', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        order.deliveryAddress['address'],
                                        order.deliveryAddress['city'],
                                      ].where((e) => e != null && e.toString().isNotEmpty).join('\n'),
                                      style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
                                    ),
                                    if ((order.deliveryAddress['phone'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(order.deliveryAddress['phone'].toString(), style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                    ],
                                    if (order.deliveryPerson.isAssigned) ...[
                                      const Divider(height: 28),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            backgroundImage: order.deliveryPerson.photoUrl.isNotEmpty
                                                ? NetworkImage(order.deliveryPerson.photoUrl)
                                                : null,
                                            child: order.deliveryPerson.photoUrl.isEmpty
                                                ? const Icon(Icons.person, color: Colors.grey)
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Livreur', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                                Row(
                                                  children: [
                                                    Text(order.deliveryPerson.name,
                                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                                    if (order.deliveryPerson.rating > 0) ...[
                                                      const SizedBox(width: 6),
                                                      const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                                                      const SizedBox(width: 2),
                                                      Text(order.deliveryPerson.rating.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (order.deliveryPerson.phone.isNotEmpty)
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                final uri = Uri.parse('tel:${order.deliveryPerson.phone}');
                                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                                              },
                                              icon: const Icon(Icons.call, size: 14, color: Color(0xFF2563EB)),
                                              label: const Text('Contacter', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12)),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color(0xFF2563EB)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Infos de paiement
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.credit_card_outlined, color: Color(0xFF2563EB), size: 20),
                                        SizedBox(width: 8),
                                        Text('Informations de paiement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark)),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text('Méthode de paiement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Non renseigné',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                        if (order.paymentReference.isNotEmpty)
                                          Text('Référence : ${order.paymentReference}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Statut du paiement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: order.paymentStatus == 'paid' ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            order.paymentStatus == 'paid' ? 'Payé' : 'En attente',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: order.paymentStatus == 'paid' ? const Color(0xFF16A34A) : const Color(0xFFC2410C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppColors.navyDark : Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: FontWeight.bold, color: color ?? AppColors.navyDark)),
      ],
    );
  }
}
