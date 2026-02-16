import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import '../../../../data/models/pharmacie_model.dart';

class MapScreenSimple extends StatefulWidget {
  final PharmacieModel pharmacie;

  const MapScreenSimple({super.key, required this.pharmacie});

  @override
  State<MapScreenSimple> createState() => _MapScreenSimpleState();
}

class _MapScreenSimpleState extends State<MapScreenSimple> {
  static final _log = Logger('MapScreen');
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

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
      });
    } catch (e) {
      _log.severe('Erreur lors de la création du marqueur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
              LatLng(widget.pharmacie.latitude, widget.pharmacie.longitude),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.vonjiaina',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
