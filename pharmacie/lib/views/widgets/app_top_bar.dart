import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearch;
  final String searchHint;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.searchController,
    this.onSearch,
    this.searchHint = 'Rechercher un produit...',
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final dashVM = context.watch<DashboardViewModel>();
    final user = authVM.currentUser;

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Titre + sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),

          // Champ de recherche
          if (onSearch != null) ...[
            SizedBox(
              width: 260,
              height: 38,
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Point 5 : Switch de garde au lieu de la cloche
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dashVM.isOnGuard ? 'De garde' : 'Hors garde',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: dashVM.isOnGuard
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Switch(
                value: dashVM.isOnGuard,
                onChanged: (val) => dashVM.setOnGuard(val),
                activeThumbColor: AppColors.success,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Menu utilisateur déroulant
          if (user != null)
            PopupMenuButton<String>(
              offset: const Offset(0, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              elevation: 8,
              color: Colors.white,
              onSelected: (value) {
                if (value == 'settings') {
                  context.go(AppRoutes.settings);
                } else if (value == 'logout') {
                  authVM.logout();
                  context.go(AppRoutes.home);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  enabled: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'settings',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Paramètres',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.role,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
