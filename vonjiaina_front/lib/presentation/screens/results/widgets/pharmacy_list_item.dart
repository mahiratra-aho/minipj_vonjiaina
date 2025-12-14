import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/pharmacie_model.dart';

class PharmacyListItem extends StatelessWidget {
  final PharmacieModel pharmacie;

  const PharmacyListItem({
    super.key,
    required this.pharmacie,
  });

  void _callPharmacy(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? AppColors.primaryLight : Colors.grey.shade200,
        foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showPharmacyDetails(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton Google Maps
                _buildMapButton(),

                const SizedBox(width: 16),

                // Informations de la pharmacie
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom + Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pharmacie.nom,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (pharmacie.isGarde) _buildGardeBadge(),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Adresse
                      if (pharmacie.adresse != null)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.08)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                pharmacie.adresse!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.08),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Distance, Prix, Stock
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (pharmacie.distanceKm != null)
                            _buildInfoChip(
                              Icons.near_me,
                              '${pharmacie.distanceKm!.toStringAsFixed(1)} km',
                              AppColors.primaryLight,
                            ),
                          if (pharmacie.prix != null)
                            _buildInfoChip(
                              Icons.payments_outlined,
                              '${pharmacie.prix!.toStringAsFixed(0)} Ar',
                              AppColors.accentTeal,
                            ),
                          if (pharmacie.quantite != null)
                            _buildInfoChip(
                              Icons.inventory_2_outlined,
                              '${pharmacie.quantite} en stock',
                              AppColors.success,
                            ),
                        ],
                      ),

                      // Statut (ouvert/fermé)
                      if (!pharmacie.isGarde) ...[
                        const SizedBox(height: 8),
                        _buildStatusBadge(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton() {
    return GestureDetector(
      onTap: _openGoogleMaps,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.directions,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildGardeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'GARDE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isOpen = pharmacie.isOuverte;
    final Color statusColor =
        isOpen ? AppColors.success : AppColors.textSecondary;
    final String statusText = isOpen ? 'Ouverte' : 'Fermée';
    final IconData statusIcon = isOpen ? Icons.check_circle : Icons.schedule;

    return Row(
      children: [
        Icon(
          statusIcon,
          size: 14,
          color: statusColor,
        ),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
        if (!isOpen && pharmacie.prochaineOuverture != null) ...[
          const SizedBox(width: 8),
          Text(
            '• ${pharmacie.prochaineOuverture}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.07),
            ),
          ),
        ],
      ],
    );
  }

  void _openGoogleMaps() async {
    final url = AppConstants.getGoogleMapsUrl(
      pharmacie.latitude,
      pharmacie.longitude,
    );

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPharmacyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDetailsSheet(context),
    );
  }

  Widget _buildDetailsSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre du haut
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nom + Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  pharmacie.nom,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (pharmacie.isGarde) _buildGardeBadge(),
            ],
          ),

          const SizedBox(height: 20),

          // Informations détaillées
          if (pharmacie.adresse != null)
            _buildDetailRow(
              Icons.location_on,
              'Adresse',
              pharmacie.adresse!,
            ),

          if (pharmacie.telephone != null)
            _buildDetailRow(
              Icons.phone,
              'Téléphone',
              pharmacie.telephone!,
              onTap: () => _callPharmacy(pharmacie.telephone!),
            ),

          if (pharmacie.distanceKm != null)
            _buildDetailRow(
              Icons.near_me,
              'Distance',
              '${pharmacie.distanceKm!.toStringAsFixed(2)} km',
            ),

          if (pharmacie.prix != null)
            _buildDetailRow(
              Icons.payments,
              'Prix',
              '${pharmacie.prix!.toStringAsFixed(0)} Ar',
            ),

          if (pharmacie.quantite != null)
            _buildDetailRow(
              Icons.inventory_2,
              'Stock disponible',
              '${pharmacie.quantite} unités',
            ),

          const SizedBox(height: 24),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Appeler',
                  Icons.phone,
                  () {
                    Navigator.pop(context);
                    if (pharmacie.telephone != null) {
                      _callPharmacy(pharmacie.telephone!);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Itinéraire',
                  Icons.directions,
                  () {
                    Navigator.pop(context);
                    _openGoogleMaps();
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.decorGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.07),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withValues(alpha: 0.05),
              ),
          ]),
        ),
      ),
    );
  }
}
