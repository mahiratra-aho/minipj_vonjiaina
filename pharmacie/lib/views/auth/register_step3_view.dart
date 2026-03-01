import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterStep3View extends StatefulWidget {
  const RegisterStep3View({super.key});

  @override
  State<RegisterStep3View> createState() => _RegisterStep3ViewState();
}

class _RegisterStep3ViewState extends State<RegisterStep3View> {
  bool _submitted = false;

  bool get _passwordsMatch {
    final vm = context.read<AuthViewModel>();
    return vm.newPassword == vm.confirmPassword;
  }

  bool get _canSubmit {
    final vm = context.read<AuthViewModel>();
    return vm.newPassword.isNotEmpty &&
        vm.confirmPassword.isNotEmpty &&
        _passwordsMatch &&
        vm.passwordStrength >= 0.6 &&
        vm.acceptCGU &&
        vm.acceptPrivacy &&
        vm.certifyInfo;
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Consumer<AuthViewModel>(
                    builder: (context, vm, _) => Column(
                      children: [
                        _buildProgress(context),
                        const SizedBox(height: 24),
                        _buildMainCard(context, vm),
                        const SizedBox(height: 16),
                        _buildTrustBadges(context),
                        const SizedBox(height: 16),
                        Text(
                          '© 2026 Vonjiaina – Tous droits réservés.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
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
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.registerStep2),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Retour à l'étape 2"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
          Text(
            'CRÉATION DE COMPTE PHARMACIEN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 120),
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
              Text(
                'Étape 3 sur 3 : Sécurité et validation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '90% complété',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.9,
              minHeight: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, AuthViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildPasswordSection(context, vm),
          const Divider(height: 1),
          _buildValidationSection(context, vm),
          const Divider(height: 1),
          _buildCardFooter(context, vm),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sécurisez votre compte',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mot de passe
          const Text(
            'Mot de passe *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: vm.setNewPassword,
            obscureText: !vm.newPasswordVisible,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.textMuted,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.newPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: vm.toggleNewPasswordVisible,
              ),
              errorText: _submitted && vm.newPassword.isEmpty
                  ? 'Ce champ est requis'
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Indicateurs de force
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXIGENCES DE SÉCURITÉ',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 24,
                  runSpacing: 6,
                  children: vm.passwordRequirements.entries
                      .map((e) => _requirementItem(e.key, e.value))
                      .toList(),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: vm.passwordStrength,
                    minHeight: 4,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: AlwaysStoppedAnimation(
                      vm.passwordStrength < 0.4
                          ? AppColors.danger
                          : vm.passwordStrength < 0.7
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Force : ${vm.passwordStrengthLabel}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: vm.passwordStrength < 0.4
                        ? AppColors.danger
                        : vm.passwordStrength < 0.7
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirmer mot de passe
          const Text(
            'Confirmer le mot de passe *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: vm.setConfirmPassword,
            obscureText: !vm.confirmPasswordVisible,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.replay_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.confirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: vm.toggleConfirmPasswordVisible,
              ),
              errorText:
                  _submitted &&
                      vm.confirmPassword.isNotEmpty &&
                      vm.newPassword != vm.confirmPassword
                  ? 'Les mots de passe ne correspondent pas'
                  : (_submitted && vm.confirmPassword.isEmpty
                        ? 'Ce champ est requis'
                        : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requirementItem(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: met ? AppColors.success : AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: met ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildValidationSection(BuildContext context, AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '6',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Validation finale',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avertissement si cases non cochées
          if (_submitted &&
              (!vm.acceptCGU || !vm.acceptPrivacy || !vm.certifyInfo))
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Vous devez accepter toutes les conditions pour continuer.',
                style: TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),

          _checkboxItem(
            context,
            text: "J'accepte les ",
            linkText: "Conditions Générales d'utilisation (CGU)",
            trailingText: " de la plateforme.",
            value: vm.acceptCGU,
            onChanged: vm.setAcceptCGU,
            hasError: _submitted && !vm.acceptCGU,
          ),
          const SizedBox(height: 10),
          _checkboxItem(
            context,
            text: "J'ai pris connaissance de la ",
            linkText: "Politique de Confidentialité",
            trailingText: " et de gestion des données.",
            value: vm.acceptPrivacy,
            onChanged: vm.setAcceptPrivacy,
            hasError: _submitted && !vm.acceptPrivacy,
          ),
          const SizedBox(height: 10),
          _checkboxItem(
            context,
            text:
                "Je certifie sur l'honneur l'exactitude des informations fournies lors de cette inscription.",
            value: vm.certifyInfo,
            onChanged: vm.setCertifyInfo,
            hasError: _submitted && !vm.certifyInfo,
          ),
        ],
      ),
    );
  }

  Widget _checkboxItem(
    BuildContext context, {
    required String text,
    String? linkText,
    String? trailingText,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError
              ? AppColors.danger
              : value
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.cardBorder,
          width: hasError ? 1.5 : 1,
        ),
        color: hasError
            ? AppColors.dangerLight
            : value
            ? AppColors.primarySurface.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(text: text),
                  if (linkText != null)
                    TextSpan(
                      text: linkText,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (trailingText != null) TextSpan(text: trailingText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, AuthViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Déjà un compte ? ",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: vm.status == AuthStatus.loading
                  ? null
                  : () async {
                      setState(() => _submitted = true);
                      if (!_canSubmit) return;

                      final ok = await vm.register();
                      if (!context.mounted) return;

                      if (ok) {
                        // Point 16 : rediriger vers la connexion après inscription
                        vm.resetRegistration();
                        context.go(AppRoutes.login);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Compte créé ! Vous pouvez maintenant vous connecter.',
                            ),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else if (vm.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(vm.errorMessage!),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.textMuted,
              ),
              child: vm.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'S\'INSCRIRE',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadges(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _badge(Icons.shield_outlined, 'SÉCURISÉ'),
        const SizedBox(width: 24),
        _badge(Icons.verified_user_outlined, 'RGPD COMPLIANT'),
        const SizedBox(width: 24),
        _badge(Icons.medical_services_outlined, 'ORDRE NATIONAL'),
      ],
    );
  }

  Widget _badge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
