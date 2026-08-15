import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../data/rdc_locations.dart';
import '../services/address_service.dart';

/// Formulaire d'adresse hiérarchique DAVIDSTORE.
/// Province -> Ville/Territoire -> Commune -> Quartier -> Avenue -> Numéro -> Référence
/// Étape 3d : connexion à AddressService (sauvegarde + validation).
class AddressFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final void Function(String addressId)? onSaved;

  const AddressFormSheet({super.key, this.existing, this.onSaved});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final AddressService _addressService = AddressService();
  final Geocoding _geocoding = Geocoding();

  RdcProvince? _selectedProvince;
  RdcCity? _selectedCity;
  String? _selectedCommune;

  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isSaving = false;
  String? _locationError;
  String? _validationError;

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _quartierController = TextEditingController();
  final TextEditingController _avenueController = TextEditingController();
  final TextEditingController _establishmentNumberController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    if (existing != null) {
      _labelController.text = existing['label']?.toString() ?? '';
      _nameController.text = existing['name']?.toString() ??
          (FirebaseAuth.instance.currentUser?.displayName ?? '');
      _phoneController.text = existing['phone']?.toString() ?? '';
      _quartierController.text = existing['quartier']?.toString() ?? '';
      _avenueController.text = existing['avenue']?.toString() ?? '';
      _establishmentNumberController.text = existing['establishmentNumber']?.toString() ?? '';
      _referenceController.text = existing['reference']?.toString() ?? '';
      _latitude = (existing['latitude'] as num?)?.toDouble();
      _longitude = (existing['longitude'] as num?)?.toDouble();

      final provinceName = existing['province']?.toString();
      final cityName = existing['city']?.toString();
      final communeName = existing['commune']?.toString();

      if (provinceName != null) {
        for (final province in RdcLocations.provinces) {
          if (province.name == provinceName && province.available) {
            _selectedProvince = province;
            break;
          }
        }
      }

      if (_selectedProvince != null && cityName != null) {
        for (final city in _selectedProvince!.cities) {
          if (city.name == cityName) {
            _selectedCity = city;
            break;
          }
        }
      }

      if (_selectedCity != null && communeName != null) {
        for (final commune in _selectedCity!.communes) {
          if (commune == communeName) {
            _selectedCommune = commune;
            break;
          }
        }
      }
    } else {
      _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
      _labelController.text = 'Domicile';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _quartierController.dispose();
    _avenueController.dispose();
    _establishmentNumberController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

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
  String _normalizeForMatch(String input) {
    var s = input.trim().toLowerCase();
    const accents = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    accents.forEach((accented, plain) {
      s = s.replaceAll(accented, plain);
    });
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  bool _looksLikePlusCode(String input) {
    return RegExp(r'^[23456789CFGHJMPQRVWX]{4,}\+[23456789CFGHJMPQRVWX]{2,}').hasMatch(input.trim());
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception('Active la localisation du téléphone.');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permission GPS refusée.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      try {
        final placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;

          final geoProvinceName = placemark.administrativeArea;
          final geoCityName = (placemark.subAdministrativeArea?.isNotEmpty ?? false)
              ? placemark.subAdministrativeArea
              : placemark.locality;
          final geoCommuneName = placemark.subLocality;
          final geoQuartierName = placemark.thoroughfare;
          final geoAvenueName = placemark.street;

          RdcProvince? matchedProvince;
          if (geoProvinceName != null) {
            final normalizedGeoProvince = _normalizeForMatch(geoProvinceName);
            for (final province in RdcLocations.provinces) {
              if (province.available &&
                  _normalizeForMatch(province.name) == normalizedGeoProvince) {
                matchedProvince = province;
                break;
              }
            }
          }

          RdcCity? matchedCity;
          if (matchedProvince != null && geoCityName != null) {
            final normalizedGeoCity = _normalizeForMatch(geoCityName);
            for (final city in matchedProvince.cities) {
              if (_normalizeForMatch(city.name) == normalizedGeoCity) {
                matchedCity = city;
                break;
              }
            }
          }

          String? matchedCommune;
          if (matchedCity != null && geoCommuneName != null && geoCommuneName.isNotEmpty) {
            final normalizedGeoCommune = _normalizeForMatch(geoCommuneName);
            for (final commune in matchedCity.communes) {
              if (_normalizeForMatch(commune) == normalizedGeoCommune) {
                matchedCommune = commune;
                break;
              }
            }
          }

          final quartierUsable = geoQuartierName != null &&
              geoQuartierName.isNotEmpty &&
              !_looksLikePlusCode(geoQuartierName);

          final avenueUsable = geoAvenueName != null &&
              geoAvenueName.isNotEmpty &&
              !_looksLikePlusCode(geoAvenueName);

          if (mounted) {
            setState(() {
              if (matchedProvince != null) _selectedProvince = matchedProvince;
              if (matchedCity != null) _selectedCity = matchedCity;
              if (matchedCommune != null) _selectedCommune = matchedCommune;
              if (_quartierController.text.isEmpty && quartierUsable) {
                _quartierController.text = geoQuartierName;
              }
              if (_avenueController.text.isEmpty && avenueUsable) {
                _avenueController.text = geoAvenueName;
              }
            });
          }
        }
      } catch (_) {
        // Géocodage inverse indisponible ou échoué : on garde uniquement
        // les coordonnées GPS brutes déjà enregistrées, sans rien supposer.
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  String? _validate() {
    if (_selectedProvince == null) return 'Sélectionne une province.';
    if (_selectedCity == null) return 'Sélectionne une ville/territoire.';
    if (_selectedCommune == null) return 'Sélectionne une commune.';
    if (_quartierController.text.trim().isEmpty) return 'Le quartier est obligatoire.';
    if (_avenueController.text.trim().isEmpty) return 'L\'avenue/rue est obligatoire.';
    if (_establishmentNumberController.text.trim().isEmpty) {
      return 'Le numéro d\'établissement est obligatoire.';
    }
    if (_referenceController.text.trim().isEmpty) {
      return 'La référence/point de repère est obligatoire.';
    }
    if (_nameController.text.trim().isEmpty) return 'Le nom complet est obligatoire.';
    if (_phoneController.text.trim().isEmpty) return 'Le téléphone est obligatoire.';
    return null;
  }

  Future<void> _save() async {
    final error = _validate();

    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    setState(() {
      _isSaving = true;
      _validationError = null;
    });

    final fullAddress =
        '${_avenueController.text.trim()}, N° ${_establishmentNumberController.text.trim()}, Q/${_quartierController.text.trim()}';

    try {
      final existingId = widget.existing?['id']?.toString();
      String addressId;

      if (existingId == null) {
        addressId = await _addressService.addAddress(
          label: _labelController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: fullAddress,
          city: _selectedCity!.name,
          latitude: _latitude,
          longitude: _longitude,
          isDefault: true,
          province: _selectedProvince!.name,
          commune: _selectedCommune,
          quartier: _quartierController.text.trim(),
          avenue: _avenueController.text.trim(),
          establishmentNumber: _establishmentNumberController.text.trim(),
          reference: _referenceController.text.trim(),
        );
      } else {
        addressId = existingId;
        await _addressService.updateAddress(
          addressId: existingId,
          label: _labelController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: fullAddress,
          city: _selectedCity!.name,
          latitude: _latitude,
          longitude: _longitude,
          isDefault: widget.existing?['isDefault'] == true,
          province: _selectedProvince!.name,
          commune: _selectedCommune,
          quartier: _quartierController.text.trim(),
          avenue: _avenueController.text.trim(),
          establishmentNumber: _establishmentNumberController.text.trim(),
          reference: _referenceController.text.trim(),
        );
      }

      if (mounted && widget.onSaved != null) {
        widget.onSaved!(addressId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _validationError = 'Impossible d\'enregistrer l\'adresse. Réessaie.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLocating ? null : _useMyLocation,
              icon: _isLocating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                _isLocating ? 'Localisation en cours...' : 'Utiliser ma position actuelle',
              ),
            ),
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _locationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 8),
            Text(
              'Position GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),

          const Text('Province *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

          const Text('Ville / Territoire *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<RdcCity>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            hint: Text(
              _selectedProvince == null ? 'Choisissez d\'abord une province' : 'Sélectionner une ville',
            ),
            items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city.name))).toList(),
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

          const Text('Commune *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedCommune,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            hint: Text(
              _selectedCity == null ? 'Choisissez d\'abord une ville' : 'Sélectionner une commune',
            ),
            items: communes.map((commune) => DropdownMenuItem(value: commune, child: Text(commune))).toList(),
            onChanged: _selectedCity == null
                ? null
                : (commune) {
                    if (commune == null) return;
                    setState(() => _selectedCommune = commune);
                  },
          ),
          const SizedBox(height: 16),

          const Text('Quartier *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _quartierController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Ex: Golf',
            ),
          ),
          const SizedBox(height: 16),

          const Text('Avenue / Rue *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _avenueController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Ex: Avenue Lumumba',
            ),
          ),
          const SizedBox(height: 16),

          const Text('Numéro d\'établissement *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _establishmentNumberController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Ex: N° 1425',
            ),
          ),
          const SizedBox(height: 16),

          const Text('Référence / Point de repère *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Ex: En face de l\'Hôpital Général',
            ),
          ),
          const SizedBox(height: 20),

          const Text('Autres détails', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              labelText: 'Libellé (ex: Domicile, Bureau)',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              labelText: 'Nom complet *',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              labelText: 'Téléphone *',
            ),
          ),

          if (_validationError != null) ...[
            const SizedBox(height: 12),
            Text(
              _validationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enregistrer cette adresse'),
            ),
          ),
        ],
      ),
    );
  }
}

