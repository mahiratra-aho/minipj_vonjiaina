import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

// ── Masque téléphone Madagascar +261 XX XX XXX XX ─────────────────────────
class _MalagasyPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extraire uniquement les chiffres (hors +261)
    String raw = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.startsWith('261')) raw = raw.substring(3);
    if (raw.length > 9) raw = raw.substring(0, 9);

    final buf = StringBuffer('+261');
    for (int i = 0; i < raw.length; i++) {
      if (i == 0) buf.write(' ');
      if (i == 2) buf.write(' ');
      if (i == 4) buf.write(' ');
      if (i == 7) buf.write(' ');
      buf.write(raw[i]);
    }

    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class RegisterStep1View extends StatefulWidget {
  const RegisterStep1View({super.key});

  @override
  State<RegisterStep1View> createState() => _RegisterStep1ViewState();
}

class _RegisterStep1ViewState extends State<RegisterStep1View> {
  bool _submitted = false;

  final _phoneCtrl = TextEditingController(text: '+261 ');
  final _urgenceCtrl = TextEditingController(text: '+261 ');
  final _nameCtrl = TextEditingController();
  final _pharmacyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Point 10 : initialiser les controllers avec les données existantes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AuthViewModel>();
      _nameCtrl.text = vm.fullName;
      _pharmacyCtrl.text = vm.pharmacyName;
      _addressCtrl.text = vm.address;
      _complementCtrl.text = vm.addressComplement;
      _emailCtrl.text = vm.proEmail;
      _phoneCtrl.text = vm.phone.isNotEmpty ? vm.phone : '+261 ';
      _urgenceCtrl.text = vm.emergencyPhone.isNotEmpty
          ? vm.emergencyPhone
          : '+261 ';
      setState(() => _submitted = false);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _urgenceCtrl.dispose();
    _nameCtrl.dispose();
    _pharmacyCtrl.dispose();
    _addressCtrl.dispose();
    _complementCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isPhoneComplete(String val) {
    final digits = val.replaceAll(RegExp(r'[^\d]'), '');
    final local = digits.startsWith('261') ? digits.substring(3) : digits;
    return local.length == 9;
  }

  bool get _canProceed {
    final vm = context.read<AuthViewModel>();
    return vm.fullName.isNotEmpty &&
        vm.role.isNotEmpty &&
        vm.pharmacyName.isNotEmpty &&
        vm.address.isNotEmpty &&
        vm.proEmail.isNotEmpty &&
        _isPhoneComplete(_phoneCtrl.text);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) {
                      return Column(
                        children: [
                          _buildProgressCard(context),
                          const SizedBox(height: 20),
                          _buildResponsibleSection(context, vm),
                          const SizedBox(height: 20),
                          _buildPharmacySection(context, vm),
                          const SizedBox(height: 24),
                          _buildActions(context, vm),
                          const SizedBox(height: 24),
                          Text(
                            '© 2026 Vonjiaina. Tous droits réservés.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
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
            'Vonjiaina',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Retour à l'accueil"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CRÉATION DE COMPTE PHARMACIEN',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Étape 1 sur 3',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Text(
                '30% complété',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.3,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibleSection(BuildContext context, AuthViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '1. Informations Responsable',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom complet
                Expanded(
                  child: _textField(
                    label: 'Nom Complet *',
                    hint: 'Jean Rakoto',
                    controller: _nameCtrl,
                    onChanged: vm.setFullName,
                    showError: _submitted && vm.fullName.isEmpty,
                    errorText: 'Ce champ est requis',
                  ),
                ),
                const SizedBox(width: 16),
                // Rôle — liste déroulante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Fonction *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        hint: const Text('Choisir un rôle'),
                        initialValue: vm.role.isEmpty ? null : vm.role,
                        onChanged: (v) => vm.setRole(v ?? ''),
                        decoration: InputDecoration(
                          errorText: _submitted && vm.role.isEmpty
                              ? 'Ce champ est requis'
                              : null,
                        ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacySection(BuildContext context, AuthViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.local_pharmacy_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '2. Informations Pharmacie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Nom de la pharmacie
                _textField(
                  label: 'Nom de la Pharmacie *',
                  hint: 'Ex: Pharmacie Analakely',
                  controller: _pharmacyCtrl,
                  onChanged: vm.setPharmacyName,
                  prefixIcon: Icons.local_pharmacy_outlined,
                  showError: _submitted && vm.pharmacyName.isEmpty,
                  errorText: 'Ce champ est requis',
                ),
                const SizedBox(height: 16),
                // Adresse + complément
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _textField(
                        label: 'Adresse *',
                        hint: 'Numéro et nom de rue',
                        controller: _addressCtrl,
                        onChanged: vm.setAddress,
                        showError: _submitted && vm.address.isEmpty,
                        errorText: 'Ce champ est requis',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _textField(
                        label: "Complément d'adresse",
                        hint: 'Bâtiment, étage…',
                        controller: _complementCtrl,
                        onChanged: vm.setAddressComplement,
                        showError: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Email + Téléphone
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'Email Professionnel *',
                        hint: 'contact@pharmacie.mg',
                        controller: _emailCtrl,
                        onChanged: vm.setProEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        showError: _submitted && vm.proEmail.isEmpty,
                        errorText: 'Ce champ est requis',
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Téléphone avec masque Madagascar
                    Expanded(
                      child: _phoneField(
                        label: 'Téléphone *',
                        controller: _phoneCtrl,
                        onChanged: vm.setPhone,
                        showError:
                            _submitted && !_isPhoneComplete(_phoneCtrl.text),
                        errorText: 'Numéro incomplet (+261 XX XX XXX XX)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Numéro d'urgence
                _phoneField(
                  label: "Numéro d'urgence (optionnel)",
                  controller: _urgenceCtrl,
                  onChanged: vm.setEmergencyPhone,
                  showError: false,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sera utilisé uniquement en cas de besoin critique',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
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
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.login),
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Annuler'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _submitted = true);
              if (_canProceed) context.go(AppRoutes.registerStep2);
            },
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

  // ── Champ texte générique ────────────────────────────────────────────────
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required bool showError,
    String? errorText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 16, color: AppColors.textMuted)
                : null,
            errorText: showError ? errorText : null,
          ),
        ),
      ],
    );
  }

  // ── Champ téléphone avec masque ──────────────────────────────────────────
  Widget _phoneField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required bool showError,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [_MalagasyPhoneFormatter()],
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.phone_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
            hintText: '+261 XX XX XXX XX',
            errorText: showError ? errorText : null,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
