import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/pharmacie_model.dart';

class PharmacyMapWidget extends StatefulWidget {
  final PharmacieModel pharmacie;
  final VoidCallback? onClose;

  const PharmacyMapWidget({
    super.key,
    required this.pharmacie,
    this.onClose,
  });

  @override
  State<PharmacyMapWidget> createState() => _PharmacyMapWidgetState();
}

class _PharmacyMapWidgetState extends State<PharmacyMapWidget> {
  static final _log = Logger('PharmacyMapWidget');
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isMapLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _log.info(
        'Initialisation de la carte pour la pharmacie: ${widget.pharmacie.nom}');
    _createMarker();
  }

  void _createMarker() {
    try {
      final marker = Marker(
        markerId: MarkerId(widget.pharmacie.id.toString()),
        position: LatLng(
          widget.pharmacie.latitude,
          widget.pharmacie.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.pharmacie.nom,
          snippet: widget.pharmacie.adresse ?? '',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      );

      setState(() {
        _markers.add(marker);
        _isMapLoading = false;
      });
      _log.info('Marqueur créé avec succès pour ${widget.pharmacie.nom}');
    } catch (e) {
      _log.severe('Erreur lors de la création du marqueur: $e');
      setState(() {
        _error = 'Erreur de création du marqueur: $e';
        _isMapLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      _mapController = controller;
      _log.info('Carte créée avec succès');
      setState(() {
        _isMapLoading = false;
      });
    } catch (e) {
      _log.severe('Erreur lors de la création de la carte: $e');
      setState(() {
        _error = 'Erreur de chargement de la carte: $e';
        _isMapLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erreur de carte',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez votre connexion internet',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isMapLoading = true;
                  });
                  _createMarker();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isMapLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de la carte...'),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.pharmacie.latitude,
                  widget.pharmacie.longitude,
                ),
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),

            // Bouton pour fermer la carte
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Bouton pour centrer sur la pharmacie
            Positioned(
              bottom: 20,
              right: 10,
              child: FloatingActionButton(
                onPressed: _centerOnPharmacy,
                backgroundColor: AppColors.accentTeal,
                child: const Icon(
                  Icons.center_focus_strong,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnPharmacy() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.pharmacie.latitude,
              widget.pharmacie.longitude,
            ),
            zoom: 17,
          ),
        ),
      );
    }
  }
}
