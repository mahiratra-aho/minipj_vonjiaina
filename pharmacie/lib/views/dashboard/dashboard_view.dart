import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pharmacie/models/activity_log_model.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/medication_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/authenticated_layout.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSettings();
    });
  }

  // Point 2 : synchronise les infos d'inscription dans les paramètres
  void _syncSettings() {
    final authVM = context.read<AuthViewModel>();
    final settingsVM = context.read<SettingsViewModel>();
    final user = authVM.currentUser;
    if (user != null) {
      settingsVM.initFromUser(
        name: user.fullName,
        role: user.role,
        email: user.email,
        pharmacyName: authVM.pharmacyName,
        address: authVM.address,
        phone: authVM.phone,
        openingHours: authVM.openingHours.toList(),
        services: authVM.services,
      );
    }
  }

  // Point 6 : générer le PDF de la liste d'expirations
  Future<void> _printExpirationList(
    BuildContext context,
    List<MedicationModel> meds,
  ) async {
    final pdf = pw.Document();
    final now = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // En-tête
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Vonjiaina Pharmacie',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Généré le $now',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Liste des médicaments expirés ou bientôt expirés',
            style: const pw.TextStyle(fontSize: 13),
          ),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 12),

          // Tableau
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _pdfCell('PRODUIT', bold: true),
                  _pdfCell('LOT', bold: true),
                  _pdfCell('DATE EXPIRATION', bold: true),
                  _pdfCell('QUANTITÉ', bold: true),
                ],
              ),
              // Lignes
              ...meds.map((m) {
                final date = DateFormat('MM/yyyy').format(m.expiryDate);
                final now2 = DateTime.now();
                final isExpired = m.expiryDate.isBefore(
                  DateTime(now2.year, now2.month),
                );
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isExpired ? PdfColors.red50 : PdfColors.orange50,
                  ),
                  children: [
                    _pdfCell(m.name),
                    _pdfCell(''),
                    _pdfCell(date),
                    _pdfCell('${m.quantity}'),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Total : ${meds.length} médicament(s)',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return AuthenticatedLayout(
          currentRoute: AppRoutes.dashboard,
          appBar: AppTopBar(
            title: 'Bonjour, ${user?.fullName ?? 'Pharmacien'} !',
            subtitle: 'Pharmacie Vonjiaina - Dashboard',
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(context, vm),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLowStockTable(context, vm)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildExpiringTable(context, vm)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActivityLog(context, vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(BuildContext context, DashboardViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            label: 'TOTAL MÉDICAMENTS',
            value: NumberFormat('#,##0').format(vm.totalMedications),
            sub: vm.totalMedications == 0
                ? 'Aucun médicament enregistré'
                : 'Dans votre inventaire',
            subColor: vm.totalMedications == 0
                ? AppColors.textMuted
                : AppColors.success,
            icon: Icons.medication,
            iconBg: AppColors.primarySurface,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            context,
            label: 'STOCK FAIBLE',
            value: vm.lowStockCount.toString(),
            sub: vm.lowStockCount == 0
                ? 'Aucun produit en alerte'
                : 'Action requise immédiate',
            subColor: vm.lowStockCount == 0
                ? AppColors.textMuted
                : AppColors.warning,
            icon: Icons.format_list_bulleted_sharp,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            context,
            label: 'EXPIRÉS / BIENTÔT EXPIRÉS',
            value: vm.expiringCount.toString(),
            sub: vm.expiringCount == 0
                ? 'Aucune expiration'
                : 'Vérifier la liste',
            subColor: vm.expiringCount == 0
                ? AppColors.textMuted
                : AppColors.danger,
            icon: Icons.history,
            iconBg: AppColors.dangerLight,
            iconColor: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: subColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockTable(BuildContext context, DashboardViewModel vm) {
    final meds = vm.lowStockMedications;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produits en rupture prochaine',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.stock),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Tout voir',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (meds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 36,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun produit en rupture prochaine',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PRODUIT',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'STOCK',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Text('STATUT', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            ...meds.take(5).map((m) => _lowStockRow(context, m)),
          ],
        ],
      ),
    );
  }

  Widget _lowStockRow(BuildContext context, MedicationModel m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(m.name, style: const TextStyle(fontSize: 14))),
          Expanded(
            child: Text(
              '${m.quantity} boîtes',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _alertBadge(m),
        ],
      ),
    );
  }

  Widget _alertBadge(MedicationModel m) {
    final isCritical = m.quantity <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.dangerLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isCritical ? 'CRITIQUE' : 'ATTENTION',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isCritical ? AppColors.danger : AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildExpiringTable(BuildContext context, DashboardViewModel vm) {
    final meds = vm.expiringMedications;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expirés / Bientôt expirés',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
                // Point 6 : bouton PDF fonctionnel
                TextButton.icon(
                  onPressed: meds.isEmpty
                      ? null
                      : () => _printExpirationList(context, meds),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text(
                    'Imprimer la liste',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (meds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 36,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun médicament expiré ou bientôt expiré',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'PRODUIT',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Text('LOT', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(width: 40),
                  Text(
                    'DATE EXPIR.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            ...meds.take(5).map((m) => _expiringRow(context, m)),
          ],
        ],
      ),
    );
  }

  Widget _expiringRow(BuildContext context, MedicationModel m) {
    final now = DateTime.now();
    final isExpired = m.expiryDate.isBefore(DateTime(now.year, now.month));
    final dateStr = DateFormat('MM/yyyy').format(m.expiryDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              m.name,
              style: TextStyle(
                fontSize: 14,
                color: isExpired ? AppColors.danger : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 80,
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 13,
                color: isExpired ? AppColors.danger : AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(BuildContext context, DashboardViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Journal d'activités récentes",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
                Text(
                  "Aujourd'hui, ${DateFormat('d MMMM', 'fr').format(DateTime.now())}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (vm.recentActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.history,
                    size: 36,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune activité enregistrée',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...vm.recentActivities.take(5).map((a) {
              IconData icon;
              Color iconColor;
              Color iconBg;
              switch (a.type) {
                case ActivityType.delivery:
                  icon = Icons.shopping_cart_outlined;
                  iconColor = AppColors.primary;
                  iconBg = AppColors.primarySurface;
                case ActivityType.update:
                  icon = Icons.edit_outlined;
                  iconColor = AppColors.info;
                  iconBg = AppColors.infoLight;
                case ActivityType.inventory:
                  icon = Icons.inventory_2_outlined;
                  iconColor = AppColors.warning;
                  iconBg = AppColors.warningLight;
                default:
                  icon = Icons.info_outline;
                  iconColor = AppColors.textSecondary;
                  iconBg = AppColors.background;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${a.timeAgo} • ${a.description}',
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
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
