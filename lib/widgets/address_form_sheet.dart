import 'package:flutter/material.dart';
import '../data/rdc_locations.dart';

/// Formulaire d'adresse hiérarchique DAVIDSTORE.
/// Province -> Ville/Territoire -> Commune -> Quartier -> Avenue -> Numéro -> Référence
/// Étape 3a : squelette + sélection Province / Ville / Commune uniquement.
class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  RdcProvince? _selectedProvince;
  RdcCity? _selectedCity;
  String? _selectedCommune;

  void _onProvinceChanged(RdcProvince province) {
    if (!province.available) {
      _showProvinceUnavailableDialog(province);
      return;
    }

    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
      _selectedCommune = null;
    });
  }

  void _showProvinceUnavailableDialog(RdcProvince province) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('📍 Province non disponible'),
        content: Text(
          'DAVIDSTORE arrive bientôt dans la province de ${province.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _openProvincePicker() async {
    final picked = await showModalBottomSheet<RdcProvince>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: RdcLocations.provinces.length,
            itemBuilder: (context, index) {
              final province = RdcLocations.provinces[index];
              final isSelected = province.name == _selectedProvince?.name;

              return ListTile(
                leading: Icon(
                  province.available ? Icons.check_circle_outline : Icons.lock_outline,
                  color: province.available ? Colors.green : Colors.grey,
                ),
                title: Text(
                  province.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: province.available ? Colors.black87 : Colors.grey,
                  ),
                ),
                trailing: Text(
                  province.available ? 'Disponible' : 'Bientôt disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: province.available ? Colors.green : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext, province);
                },
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      _onProvinceChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = _selectedProvince?.cities ?? const [];
    final communes = _selectedCity?.communes ?? const [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Province *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _openProvincePicker,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Text(
                _selectedProvince?.name ?? 'Sélectionner une province',
                style: TextStyle(
                  color: _selectedProvince == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Ville / Territoire *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<RdcCity>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            hint: Text(
              _selectedProvince == null
                  ? 'Choisissez d\'abord une province'
                  : 'Sélectionner une ville',
            ),
            items: cities
                .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city.name),
                    ))
                .toList(),
            onChanged: _selectedProvince == null
                ? null
                : (city) {
                    if (city == null) return;
                    setState(() {
                      _selectedCity = city;
                      _selectedCommune = null;
                    });
                  },
          ),
          const SizedBox(height: 16),

          const Text(
            'Commune *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedCommune,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            hint: Text(
              _selectedCity == null
                  ? 'Choisissez d\'abord une ville'
                  : 'Sélectionner une commune',
            ),
            items: communes
                .map((commune) => DropdownMenuItem(
                      value: commune,
                      child: Text(commune),
                    ))
                .toList(),
            onChanged: _selectedCity == null
                ? null
                : (commune) {
                    if (commune == null) return;
                    setState(() => _selectedCommune = commune);
                  },
          ),
        ],
      ),
    );
  }
}

