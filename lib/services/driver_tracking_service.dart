import 'package:cloud_firestore/cloud_firestore.dart';

/// Infos minimales d'un livreur, lues en temps réel depuis livreurs/{driverId}
/// (même collection que Delivery-app et le dashboard admin) pour afficher son
/// statut en direct sur l'écran de suivi de commande.
class DriverTrackingInfo {
  final String status;
  final GeoPoint? location;

  const DriverTrackingInfo({required this.status, this.location});

  bool get isEnRoute => status == 'en_livraison';

  factory DriverTrackingInfo.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DriverTrackingInfo(
      status: data['status']?.toString() ?? 'hors_ligne',
      location: data['location'] as GeoPoint?,
    );
  }
}

class DriverTrackingService {
  final _livreurs = FirebaseFirestore.instance.collection('livreurs');

  /// Écoute en temps réel le document du livreur assigné à une commande.
  Stream<DriverTrackingInfo?> watchDriver(String driverId) {
    return _livreurs.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DriverTrackingInfo.fromDoc(doc);
    });
  }
}
