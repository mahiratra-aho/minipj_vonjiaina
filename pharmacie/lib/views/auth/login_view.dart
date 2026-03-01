import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildLoginCard(context),
                    const SizedBox(height: 24),
                    _buildFooter(context),
                  ],
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
      height: 60,
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
            label: const Text('Retour à l\'accueil'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Container(
          width: 420,
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Portail Professionnel',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez votre pharmacie en toute sécurité',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Email
              _buildLabel(context, 'Email professionnel'),
              const SizedBox(height: 6),
              TextField(
                onChanged: vm.setEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'nom@pharmacie.com',
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              _buildLabel(context, 'Mot de passe'),
              const SizedBox(height: 6),
              TextField(
                onChanged: vm.setPassword,
                obscureText: !vm.passwordVisible,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      vm.passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: vm.togglePasswordVisible,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remember me + forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: vm.rememberMe,
                        onChanged: (v) => vm.setRememberMe(v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text(
                        'Se souvenir de moi',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error
              if (vm.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),

              // Login button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: vm.status == AuthStatus.loading
                      ? null
                      : () async {
                          final ok = await vm.login();
                          if (ok && context.mounted) {
                            context.go(AppRoutes.dashboard);
                          }
                        },
                  icon: vm.status == AuthStatus.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login, size: 18),
                  label: const Text(
                    'SE CONNECTER',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider OU
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte ?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.registerStep1),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.only(left: 4),
                    ),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _footerLink('Mentions légales'),
        const SizedBox(width: 20),
        _footerLink('Politique de confidentialité'),
        const SizedBox(width: 20),
        _footerLink('Support technique'),
      ],
    );
  }

  Widget _footerLink(String label) {
    return Text(
      label,
      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
