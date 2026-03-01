import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/authenticated_layout.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _managerNameCtrl;
  late TextEditingController _pharmacyNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<SettingsViewModel>();
    _managerNameCtrl = TextEditingController(text: vm.managerName);
    _pharmacyNameCtrl = TextEditingController(text: vm.pharmacyName);
    _emailCtrl = TextEditingController(text: vm.email);
    _addressCtrl = TextEditingController(text: vm.address);
    _phoneCtrl = TextEditingController(text: vm.phone);
  }

  @override
  void dispose() {
    _managerNameCtrl.dispose();
    _pharmacyNameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return AuthenticatedLayout(
          currentRoute: AppRoutes.settings,
          appBar: AppTopBar(title: ''),
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paramètres',
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Gérez les informations de votre officine, vos horaires et votre sécurité.",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (vm.successMessage != null) ...[
                            const SizedBox(height: 16),
                            _successBanner(vm.successMessage!),
                          ],
                          if (vm.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _errorBanner(vm.errorMessage!),
                          ],
                          const SizedBox(height: 24),
                          _buildPharmacyInfo(context, vm),
                          const SizedBox(height: 20),
                          _buildScheduleAndServices(context, vm),
                          const SizedBox(height: 20),
                          _buildSecurity(context, vm),
                          const SizedBox(height: 20),
                          _buildDangerZone(context, vm),
                          const SizedBox(height: 24),
                          _buildSaveActions(context, vm),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _successBanner(String msg) => _banner(
    msg,
    AppColors.successLight,
    AppColors.success,
    Icons.check_circle,
  );
  Widget _errorBanner(String msg) => _banner(
    msg,
    AppColors.dangerLight,
    AppColors.danger,
    Icons.error_outline,
  );

  Widget _banner(String msg, Color bg, Color fg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Text(
            msg,
            style: TextStyle(color: fg, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyInfo(BuildContext context, SettingsViewModel vm) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        // Update controllers when data changes
        _managerNameCtrl.text = vm.managerName;
        _pharmacyNameCtrl.text = vm.pharmacyName;
        _emailCtrl.text = vm.email;
        _addressCtrl.text = vm.address;
        _phoneCtrl.text = vm.phone;

        return _sectionCard(
          context,
          icon: Icons.local_pharmacy_outlined,
          title: 'Informations de la Pharmacie',
          trailing: TextButton(
            onPressed: () => vm.setEditing(!vm.isEditing),
            child: Text(
              vm.isEditing ? 'Annuler' : 'Modifier tout',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _stableField(
                      label: 'Nom du gérant',
                      controller: _managerNameCtrl,
                      onChanged: vm.setManagerName,
                      enabled: vm.isEditing,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Rôle — liste déroulante
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rôle',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue:
                              SettingsViewModel.availableRoles.contains(
                                vm.managerRole,
                              )
                              ? vm.managerRole
                              : null,
                          hint: const Text(
                            'Sélectionner un rôle',
                            style: TextStyle(fontSize: 14),
                          ),
                          onChanged: vm.isEditing
                              ? (val) {
                                  if (val != null) vm.setManagerRole(val);
                                }
                              : null,
                          items: SettingsViewModel.availableRoles
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: vm.isEditing
                                ? Colors.white
                                : AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _stableField(
                      label: 'Nom de la pharmacie',
                      controller: _pharmacyNameCtrl,
                      onChanged: vm.setPharmacyName,
                      enabled: vm.isEditing,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _stableField(
                      label: 'Email professionnel',
                      controller: _emailCtrl,
                      onChanged: vm.setEmail,
                      enabled: vm.isEditing,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _stableField(
                label: 'Adresse',
                controller: _addressCtrl,
                onChanged: vm.setAddress,
                enabled: vm.isEditing,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                child: _stableField(
                  label: 'Téléphone',
                  controller: _phoneCtrl,
                  onChanged: vm.setPhone,
                  enabled: vm.isEditing,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleAndServices(BuildContext context, SettingsViewModel vm) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return _sectionCard(
          context,
          icon: Icons.schedule_outlined,
          title: 'Horaires & Services',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Horaires éditables ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HORAIRES D'OUVERTURE",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: vm.openingHours.asMap().entries.map((entry) {
                          final i = entry.key;
                          final h = entry.value;
                          final isLast = i == vm.openingHours.length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                        color: AppColors.divider,
                                      ),
                                    ),
                              color: h.isClosed
                                  ? AppColors.background
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    h.day,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: h.isClosed
                                          ? AppColors.textMuted
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                // Heure ouverture
                                Expanded(
                                  child: h.isClosed
                                      ? const Text(
                                          '—',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                          ),
                                        )
                                      : _timeChip(
                                          context,
                                          h.openTime ?? '08:00',
                                          () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: _parseTime(
                                                h.openTime ?? '08:00',
                                              ),
                                            );
                                            if (time != null) {
                                              final formatted =
                                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                              vm.updateOpeningHours(
                                                i,
                                                h.copyWith(openTime: formatted),
                                              );
                                            }
                                          },
                                        ),
                                ),
                                // Heure fermeture
                                Expanded(
                                  child: h.isClosed
                                      ? const Text(
                                          '—',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                          ),
                                        )
                                      : _timeChip(
                                          context,
                                          h.closeTime ?? '19:00',
                                          () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: _parseTime(
                                                h.closeTime ?? '19:00',
                                              ),
                                            );
                                            if (time != null) {
                                              final formatted =
                                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                              vm.updateOpeningHours(
                                                i,
                                                h.copyWith(
                                                  closeTime: formatted,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                ),
                                // Toggle Fermé
                                SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: h.isClosed,
                                        onChanged: (val) {
                                          vm.updateOpeningHours(
                                            i,
                                            h.copyWith(
                                              isClosed: val ?? false,
                                              openTime: val == true
                                                  ? null
                                                  : (h.openTime),
                                              closeTime: val == true
                                                  ? null
                                                  : (h.closeTime),
                                            ),
                                          );
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
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
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // ── Services disponibles ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SERVICES DISPONIBLES',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 12),
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
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
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurity(BuildContext context, SettingsViewModel vm) {
    return _sectionCard(
      context,
      icon: Icons.security_outlined,
      title: 'Sécurité',
      child: Column(
        children: [
          _passwordField(
            'Mot de passe actuel',
            vm.setCurrentPassword,
            vm.currentPasswordVisible,
            vm.toggleCurrentPasswordVisible,
          ),
          const SizedBox(height: 16),
          _passwordField(
            'Nouveau mot de passe',
            vm.setNewPassword,
            vm.newPasswordVisible,
            vm.toggleNewPasswordVisible,
          ),
          const SizedBox(height: 16),
          _passwordField(
            'Confirmer le nouveau mot de passe',
            vm.setConfirmPassword,
            vm.confirmPasswordVisible,
            vm.toggleConfirmPasswordVisible,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: vm.isSaving ? null : () => vm.updatePassword(),
              child: const Text('Mettre à jour le mot de passe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, SettingsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suppression de compte',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supprimer le compte',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Cette action est irréversible. Toutes les données seront définitivement supprimées.",
                      style: TextStyle(
                        color: AppColors.danger.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _showDeleteAccountDialog(context, vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('Suppression de compte'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveActions(BuildContext context, SettingsViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => vm.setEditing(false),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: vm.isSaving ? null : () => vm.saveSettings(),
          child: vm.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Enregistrer toutes les modifications',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _stableField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool enabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(
    String label,
    ValueChanged<String> onChanged,
    bool visible,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          obscureText: !visible,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: toggle,
            ),
          ),
        ),
      ],
    );
  }

  // Point 1 : suppression réelle du compte
  void _showDeleteAccountDialog(
    BuildContext context,
    SettingsViewModel settingsVM,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Suppression de compte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cette action est irréversible. Toutes vos données seront définitivement supprimées et vous ne pourrez plus vous connecter avec ce compte.",
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Êtes-vous absolument sûr de vouloir continuer ?',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Réinitialise les données et déconnecte
              settingsVM.resetAllData();
              context.read<AuthViewModel>().logout();
              context.go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }
}
