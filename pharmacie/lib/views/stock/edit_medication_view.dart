import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/medication_model.dart';
import '../../viewmodels/stock_viewmodel.dart';
import '../widgets/authenticated_layout.dart';

class EditMedicationView extends StatefulWidget {
  final String medicationId;
  const EditMedicationView({super.key, required this.medicationId});

  @override
  State<EditMedicationView> createState() => _EditMedicationViewState();
}

class _EditMedicationViewState extends State<EditMedicationView> {
  bool _initialized = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _seuilCtrl;
  // ignore: unused_field
  late TextEditingController _lotCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer<StockViewModel>(
      builder: (context, vm, _) {
        if (!_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.loadMedicationForEdit(widget.medicationId);
            final med = vm.getMedicationById(widget.medicationId);
            if (med != null) {
              _nameCtrl = TextEditingController(text: med.name);
              _dosageCtrl = TextEditingController(text: med.dosage);
              _quantityCtrl = TextEditingController(
                text: med.quantity.toString(),
              );
              _seuilCtrl = TextEditingController(
                text: med.minThreshold.toString(),
              );
              _lotCtrl = TextEditingController(text: med.lotNumber);
            } else {
              _nameCtrl = _dosageCtrl = _quantityCtrl = _seuilCtrl = _lotCtrl =
                  TextEditingController();
            }
            setState(() => _initialized = true);
          });
          return const SizedBox();
        }

        final med = vm.getMedicationById(widget.medicationId);

        return AuthenticatedLayout(
          currentRoute: AppRoutes.stock,
          child: med == null
              ? const Center(child: Text('Médicament non trouvé'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, med),
                      const SizedBox(height: 24),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            children: [
                              _buildFormCard(context, vm, med),
                              const SizedBox(height: 20),
                              _buildDangerZone(context, vm, med),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, MedicationModel med) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go(AppRoutes.stock),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Retour au stock',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Modifier le médicament',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'Lot: ${med.lotNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // Badge statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _statusColor(med.status).withValues(alpha: 0.3),
            ),
            color: _statusColor(med.status).withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor(med.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'STOCK: ${med.status.label}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _statusColor(med.status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(MedicationStatus s) {
    switch (s) {
      case MedicationStatus.available:
        return AppColors.success;
      case MedicationStatus.lowStock:
        return AppColors.info;
      case MedicationStatus.veryRare:
        return AppColors.warning;
      case MedicationStatus.outOfStock:
        return AppColors.danger;
    }
  }

  Widget _buildFormCard(
    BuildContext context,
    StockViewModel vm,
    MedicationModel med,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nom + Catégorie ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field('Nom du médicament', _nameCtrl, vm.setFormName),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Catégorie'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<MedicationCategory>(
                      initialValue: vm.formCategory ?? med.category,
                      isExpanded: true,
                      onChanged: vm.setFormCategory,
                      items: MedicationCategory.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Dosage + Date d'expiration (lecture seule) ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _field('Dosage', _dosageCtrl, vm.setFormDosage)),
              const SizedBox(width: 20),
              // Point 9 : date d'expiration non modifiable
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Date de péremption (non modifiable)'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MM/yyyy').format(med.expiryDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La date d\'expiration ne peut pas être modifiée.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quantité + Seuil ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Quantité en stock'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        vm.setFormQuantity(int.tryParse(v) ?? 0);
                        setState(() {});
                      },
                      style: TextStyle(
                        color: vm.formQuantity <= med.minThreshold
                            ? AppColors.danger
                            : AppColors.textPrimary,
                        fontWeight: vm.formQuantity <= med.minThreshold
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'unités',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: vm.formQuantity <= med.minThreshold
                                ? AppColors.danger.withValues(alpha: 0.4)
                                : AppColors.cardBorder,
                          ),
                        ),
                      ),
                    ),
                    if (vm.formQuantity <= med.minThreshold)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Seuil critique (min: ${med.minThreshold})',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _field(
                  'Seuil minimum',
                  _seuilCtrl,
                  (v) => vm.setFormMinThreshold(int.tryParse(v) ?? 10),
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Actions ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            vm.setFormName(_nameCtrl.text);
                            vm.setFormDosage(_dosageCtrl.text);
                            final ok = await vm.updateMedication(
                              widget.medicationId,
                            );
                            if (ok && context.mounted) {
                              context.go(AppRoutes.stock);
                            }
                          },
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text(
                      'METTRE À JOUR',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.stock),
                  child: const Text(
                    'ANNULER',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(
    BuildContext context,
    StockViewModel vm,
    MedicationModel med,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        color: AppColors.dangerLight.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zone de Danger',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supprimer définitivement ce médicament et son historique.',
                  style: TextStyle(
                    color: AppColors.danger.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showDeleteConfirm(context, vm, med),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              'SUPPRIMER',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    StockViewModel vm,
    MedicationModel med,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text('Supprimer définitivement "${med.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await vm.deleteMedication(med.id);
              if (ok && context.mounted) context.go(AppRoutes.stock);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    ValueChanged<String> onChanged, {
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          keyboardType: keyboard,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  );
}
