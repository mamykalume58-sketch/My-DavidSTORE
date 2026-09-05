import 'package:flutter/material.dart';

enum SortOption { newest, priceAsc, priceDesc, nameAsc }

class CatalogSortModal extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;

  const CatalogSortModal({super.key, required this.currentSort, required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          const Text('Trier les produits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          _buildOption(context, SortOption.newest, 'Plus récents', Icons.schedule),
          _buildOption(context, SortOption.priceAsc, 'Prix : du - cher au + cher', Icons.arrow_upward),
          _buildOption(context, SortOption.priceDesc, 'Prix : du + cher au - cher', Icons.arrow_downward),
          _buildOption(context, SortOption.nameAsc, 'Nom (A-Z)', Icons.sort_by_alpha),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, SortOption option, String title, IconData icon) {
    final isSelected = currentSort == option;
    final primaryColor = Theme.of(context).primaryColor;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isSelected ? primaryColor : Colors.grey.shade600),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryColor : const Color(0xFF334155))),
      trailing: isSelected ? Icon(Icons.check_circle, color: primaryColor) : null,
      onTap: () {
        onSortSelected(option);
        Navigator.pop(context);
      },
    );
  }
}
