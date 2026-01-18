import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarker();
  }

  void _createMarker() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
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
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
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
