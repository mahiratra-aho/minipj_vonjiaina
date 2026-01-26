import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/pharmacie_model.dart';

class MapScreen extends StatefulWidget {
  final PharmacieModel pharmacie;

  const MapScreen({super.key, required this.pharmacie});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final _log = Logger('MapScreen');
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
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
      _log.info(
          'Création du marqueur pour ${widget.pharmacie.nom} à la position ${widget.pharmacie.latitude}, ${widget.pharmacie.longitude}');

      final marker = Marker(
        point: LatLng(widget.pharmacie.latitude, widget.pharmacie.longitude),
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      );

      setState(() {
        _markers.add(marker);
        _isMapLoading = false;
      });
      _log.info('Marqueur créé avec succès pour ${widget.pharmacie.nom}');
    } catch (e, stackTrace) {
      _log.severe('Erreur lors de la création du marqueur: $e');
      _log.severe('Stack trace: $stackTrace');
      setState(() {
        _error = 'Erreur de création du marqueur: ${e.toString()}';
        _isMapLoading = false;
      });
    }
  }

  void _centerOnPharmacy() {
    _mapController.move(
      LatLng(widget.pharmacie.latitude, widget.pharmacie.longitude),
      17.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pharmacie.nom,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Informations de la pharmacie
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pharmacie.adresse ?? 'Adresse non disponible',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.pharmacie.telephone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.pharmacie.telephone!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.pharmacie.distanceKm != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.pharmacie.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Carte OpenStreetMap
          Expanded(
            child: _buildMap(),
          ),

          // Bouton d'action
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _openGoogleMaps,
              icon: const Icon(Icons.directions),
              label: const Text('Voir l\'itinéraire dans Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_error != null) {
      return Container(
        margin: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  widget.pharmacie.latitude,
                  widget.pharmacie.longitude,
                ),
                initialZoom: 15.0,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.vonjiaina_front',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
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

  void _openGoogleMaps() async {
    final url = AppConstants.getGoogleMapsUrl(
      widget.pharmacie.latitude,
      widget.pharmacie.longitude,
    );

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
