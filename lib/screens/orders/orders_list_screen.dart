import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';
import '../../utils/price_formatter.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _selectedFilter = 'Toutes';

  final List<String> _filters = ['Toutes', 'En cours', 'Expédiées', 'Livrées', 'Annulées'];

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  bool _matchesFilter(String status) {
    switch (_selectedFilter) {
      case 'En cours':
        return status == 'pending' || status == 'preparing';
      case 'Expédiées':
        return status == 'shipped' || status == 'in_transit' || status == 'out_for_delivery';
      case 'Livrées':
        return status == 'delivered';
      case 'Annulées':
        return status == 'cancelled';
      default:
        return true;
    }
  }

  Map<String, dynamic> _statusStyle(String status) {
    switch (status) {
      case 'delivered':
        return {'label': 'Livrée', 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFDCFCE7), 'icon': Icons.check};
      case 'shipped':
      case 'in_transit':
      case 'out_for_delivery':
        return {'label': 'Expédiée', 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFDBEAFE), 'icon': Icons.local_shipping_outlined};
      case 'cancelled':
        return {'label': 'Annulée', 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEE2E2), 'icon': Icons.close};
      default:
        return {'label': 'Confirmée', 'color': const Color(0xFFC2410C), 'bg': const Color(0xFFFFEDD5), 'icon': Icons.hourglass_empty};
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${mois[date.month - 1]} ${date.year} à $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text('Mes commandes',
            style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: userId == null
          ? const Center(child: Text('Connecte-toi pour voir tes commandes'))
          : Column(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final selected = filter == _selectedFilter;
                      return InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.navyDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppColors.navyDark : Colors.grey.shade300),
                          ),
                          alignment: Alignment.center,
                          child: Text(filter,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : AppColors.textGrey)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: userId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final orders = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return OrderModel.fromMap(data);
                      }).where((o) => _matchesFilter(o.status)).toList();

                      if (orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.textGrey),
                              const SizedBox(height: 16),
                              const Text('Aucune commande pour le moment',
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final style = _statusStyle(order.status);
                          final firstItem = order.items.isNotEmpty ? order.items.first : null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Commande #${order.orderNumber}',
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                          const SizedBox(height: 2),
                                          Text(_formatDate(order.createdAt),
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: style['bg'] as Color,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(style['icon'] as IconData, size: 13, color: style['color'] as Color),
                                          const SizedBox(width: 4),
                                          Text(style['label'] as String,
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: style['color'] as Color)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (firstItem != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(firstItem.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                            const SizedBox(height: 2),
                                            Text('Quantité : ${firstItem.quantity}',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ),
                                      Text(formatPrice(firstItem.price),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navyDark)),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.credit_card, size: 15, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    Text(formatPrice(order.total),
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, '/order-detail', arguments: order.id),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Voir les détails',
                                            style: TextStyle(color: AppColors.navyDark, fontSize: 13, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.chevron_right, size: 16, color: AppColors.navyDark),
                                      ],
                                    ),
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
