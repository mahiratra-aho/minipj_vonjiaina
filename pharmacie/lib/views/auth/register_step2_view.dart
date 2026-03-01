import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/pharmacy_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterStep2View extends StatefulWidget {
  const RegisterStep2View({super.key});

  @override
  State<RegisterStep2View> createState() => _RegisterStep2ViewState();
}

class _RegisterStep2ViewState extends State<RegisterStep2View> {
  // Controllers pour les heures — un par ligne (open + close)
  late List<TextEditingController> _openCtrls;
  late List<TextEditingController> _closeCtrls;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AuthViewModel>();
    _openCtrls = vm.openingHours
        .map((h) => TextEditingController(text: h.openTime ?? '08:00'))
        .toList();
    _closeCtrls = vm.openingHours
        .map((h) => TextEditingController(text: h.closeTime ?? '19:00'))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _openCtrls) {
      c.dispose();
    }
    for (final c in _closeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(
    BuildContext context,
    int index,
    bool isOpen,
    AuthViewModel vm,
  ) async {
    final ctrl = isOpen ? _openCtrls[index] : _closeCtrls[index];
    final parts = ctrl.text.split(':');
    final init = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    ctrl.text = formatted;

    final current = vm.openingHours[index];
    vm.updateOpeningHours(
      index,
      current.copyWith(
        openTime: isOpen ? formatted : current.openTime,
        closeTime: !isOpen ? formatted : current.closeTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      return Column(
                        children: [
                          _buildProgress(context),
                          const SizedBox(height: 24),
                          _buildScheduleSection(context, vm),
                          const SizedBox(height: 24),
                          _buildServicesSection(context, vm),
                          const SizedBox(height: 24),
                          _buildActions(context, vm),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CRÉATION DE COMPTE PHARMACIEN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.registerStep1),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Retour à l'étape 1"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÉTAPE 2 SUR 3',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Configuration des horaires et services',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Text(
                '60%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // Point 11 : plus de type d'horaire, juste tableau éditable par jour
  Widget _buildScheduleSection(BuildContext context, AuthViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Horaires d'ouverture",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur une heure pour la modifier. Cochez "Fermé" si la pharmacie ne travaille pas ce jour.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Tableau des horaires
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 90),
                      Expanded(
                        child: Text(
                          'OUVERTURE',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'FERMETURE',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...vm.openingHours.asMap().entries.map((entry) {
                  return _hoursRow(context, vm, entry.key, entry.value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hoursRow(
    BuildContext context,
    AuthViewModel vm,
    int index,
    OpeningHours hours,
  ) {
    final isLast = index == vm.openingHours.length - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
        color: hours.isClosed ? AppColors.background : Colors.transparent,
      ),
      child: Row(
        children: [
          // Nom du jour
          SizedBox(
            width: 90,
            child: Text(
              hours.day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hours.isClosed
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Heure ouverture
          Expanded(
            child: hours.isClosed
                ? const Text('—', style: TextStyle(color: AppColors.textMuted))
                : _timeChip(
                    context,
                    _openCtrls[index].text,
                    () => _pickTime(context, index, true, vm),
                  ),
          ),
          // Heure fermeture
          Expanded(
            child: hours.isClosed
                ? const Text('—', style: TextStyle(color: AppColors.textMuted))
                : _timeChip(
                    context,
                    _closeCtrls[index].text,
                    () => _pickTime(context, index, false, vm),
                  ),
          ),
          // Toggle Fermé
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Checkbox(
                  value: hours.isClosed,
                  onChanged: (val) {
                    vm.updateOpeningHours(
                      index,
                      hours.copyWith(
                        isClosed: val ?? false,
                        openTime: val == true ? null : (_openCtrls[index].text),
                        closeTime: val == true
                            ? null
                            : (_closeCtrls[index].text),
                      ),
                    );
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  'Fermé',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(BuildContext context, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
          color: AppColors.primarySurface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Point 4 : nouveaux services
  Widget _buildServicesSection(BuildContext context, AuthViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Services disponibles',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.services.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => vm.toggleService(s.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: s.isEnabled
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: s.isEnabled ? 1.5 : 1,
                    ),
                    color: s.isEnabled
                        ? AppColors.primarySurface
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: s.isEnabled,
                        onChanged: (_) => vm.toggleService(s.id),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: s.isEnabled
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: s.isEnabled
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AuthViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => context.go(AppRoutes.registerStep1),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Retour'),
        ),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.registerStep3),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text(
              'SUIVANT',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }
}
