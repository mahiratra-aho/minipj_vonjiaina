import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/medication_model.dart';
import '../../viewmodels/stock_viewmodel.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/authenticated_layout.dart';
import '../widgets/status_badge.dart';

class StockListView extends StatefulWidget {
  const StockListView({super.key});

  @override
  State<StockListView> createState() => _StockListViewState();
}

class _StockListViewState extends State<StockListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockViewModel>(
      builder: (context, vm, _) {
        return AuthenticatedLayout(
          currentRoute: AppRoutes.stock,
          appBar: AppTopBar(
            title: 'Gestion du Stock',
            subtitle: '${vm.totalCount} médicament(s) au total',
            searchController: _searchCtrl,
            onSearch: vm.setSearchQuery,
            searchHint: 'Rechercher par nom, catégorie, lot…',
          ),
          child: Column(
            children: [
              _buildActions(context, vm),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildFilters(context, vm),
                      const SizedBox(height: 16),
                      if (vm.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (vm.totalCount == 0)
                        _buildEmptyState(context)
                      else
                        _buildList(context, vm),
                      const SizedBox(height: 16),
                      if (vm.totalCount > 0) _buildPagination(context, vm),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, StockViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Compteurs
          Row(
            children: [
              _statChip(
                '${vm.lowStockCount}',
                'stock faible',
                AppColors.warning,
                AppColors.warningLight,
              ),
              const SizedBox(width: 8),
              _statChip(
                '${vm.outOfStockCount}',
                'en rupture',
                AppColors.danger,
                AppColors.dangerLight,
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.importFile),
            icon: const Icon(Icons.upload_file, size: 16),
            label: const Text('Importer fichier'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.addMedication),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'AJOUTER',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String count, String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, StockViewModel vm) {
    const filters = [
      (StockFilter.all, 'Tous'),
      (StockFilter.available, 'Disponible'),
      (StockFilter.lowStock, 'Stock faible'),
      (StockFilter.expiringSoon, 'Exp./Bientôt exp.'),
      (StockFilter.outOfStock, 'En rupture'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = vm.activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => vm.setFilter(f.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isActive
                      ? null
                      : Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun médicament en stock',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Importez un fichier CSV/XLSX ou ajoutez des médicaments manuellement.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.importFile),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Importer un fichier'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.addMedication),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter manuellement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, StockViewModel vm) {
    if (vm.paginatedMedications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Text(
            'Aucun médicament correspond à votre recherche.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Column(
      children: vm.paginatedMedications
          .map((med) => _medicationCard(context, vm, med))
          .toList(),
    );
  }

  Widget _medicationCard(
    BuildContext context,
    StockViewModel vm,
    MedicationModel med,
  ) {
    Color? borderLeft;
    switch (med.status) {
      case MedicationStatus.outOfStock:
        borderLeft = AppColors.danger;
        break;
      case MedicationStatus.veryRare:
        borderLeft = AppColors.warning;
        break;
      case MedicationStatus.lowStock:
        borderLeft = AppColors.info;
        break;
      default:
        borderLeft = null;
    }

    // Expiration coloration
    Color expiryColor = AppColors.textSecondary;
    if (med.isExpired) {
      expiryColor = AppColors.danger;
    } else if (med.isExpiringSoon) {
      expiryColor = AppColors.warning;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (borderLeft != null)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: borderLeft,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Icône catégorie
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nom + infos
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            med.category.displayName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: med.isExpired || med.isExpiringSoon
                                    ? expiryColor
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Exp: ${DateFormat('MM/yyyy').format(med.expiryDate)}'
                                '${med.isExpired
                                    ? ' — EXPIRÉ'
                                    : med.isExpiringSoon
                                    ? ' — BIENTÔT EXPIRÉ'
                                    : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: expiryColor,
                                  fontWeight:
                                      med.isExpiringSoon || med.isExpired
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: med.isCritical
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${med.quantity} unités',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: med.isCritical
                                      ? AppColors.danger
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Statut + barre
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(status: med.status),
                              Text(
                                '${(med.stockPercentage * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: med.stockPercentage,
                              minHeight: 5,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: AlwaysStoppedAnimation(
                                _progressColor(med.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),
                    // Actions
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => context.go('/stock/edit/${med.id}'),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.danger,
                      ),
                      onPressed: () => _showDeleteDialog(context, vm, med),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(MedicationStatus s) {
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

  void _showDeleteDialog(
    BuildContext context,
    StockViewModel vm,
    MedicationModel med,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Supprimer le médicament'),
        content: Text('Voulez-vous vraiment supprimer "${med.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.deleteMedication(med.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, StockViewModel vm) {
    final total = vm.filteredMedications.length;
    if (total == 0) return const SizedBox();
    final start = (vm.currentPage - 1) * 10 + 1;
    final end = (vm.currentPage * 10).clamp(0, total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$start – $end sur $total médicament(s)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            _pageBtn(
              '<',
              vm.currentPage > 1 ? () => vm.setPage(vm.currentPage - 1) : null,
            ),
            ...List.generate(vm.totalPages.clamp(0, 5), (i) {
              final page = i + 1;
              return _pageBtn(
                page.toString(),
                () => vm.setPage(page),
                isActive: vm.currentPage == page,
              );
            }),
            if (vm.totalPages > 5) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('…', style: TextStyle(color: AppColors.textMuted)),
              ),
              _pageBtn(
                vm.totalPages.toString(),
                () => vm.setPage(vm.totalPages),
              ),
            ],
            _pageBtn(
              '>',
              vm.currentPage < vm.totalPages
                  ? () => vm.setPage(vm.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _pageBtn(String label, VoidCallback? onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? null
              : Border.all(
                  color: onTap != null
                      ? AppColors.cardBorder
                      : Colors.transparent,
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive
                  ? Colors.white
                  : onTap != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
