import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/medication_model.dart';
import '../../viewmodels/stock_viewmodel.dart';
import '../widgets/authenticated_layout.dart';

class AddMedicationView extends StatefulWidget {
  const AddMedicationView({super.key});

  @override
  State<AddMedicationView> createState() => _AddMedicationViewState();
}

class _AddMedicationViewState extends State<AddMedicationView> {
  bool _submitted = false;
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _lotCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _lotCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  // Point 15 : 5 ans maximum à partir d'aujourd'hui
  List<int> get _availableYears {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now + i); // maintenant jusqu'à now+5
  }

  bool _canSubmit(StockViewModel vm) =>
      _nameCtrl.text.isNotEmpty &&
      vm.formCategory != null &&
      vm.formMonth != null &&
      vm.formYear != null;

  @override
  Widget build(BuildContext context) {
    return Consumer<StockViewModel>(
      builder: (context, vm, _) => AuthenticatedLayout(
        currentRoute: AppRoutes.stock,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb
              GestureDetector(
                onTap: () => context.go(AppRoutes.stock),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Retour à la liste de stock',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ajouter un médicament',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                'Remplissez les détails ci-dessous pour ajouter un nouveau produit à votre inventaire.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      _buildFormCard(context, vm),
                      const SizedBox(height: 16),
                      _buildTip(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, StockViewModel vm) {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nom ───────────────────────────────────────────────────
                _label('Nom du médicament *'),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      onChanged: (v) {
                        vm.setFormName(v);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: Amoxicilline 500mg',
                        errorText: _submitted && _nameCtrl.text.isEmpty
                            ? 'Champ requis'
                            : null,
                      ),
                    ),
                    if (vm.nameSuggestions.isNotEmpty)
                      Positioned(
                        top: 48,
                        left: 0,
                        right: 0,
                        child: _buildSuggestions(context, vm),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Catégorie + Dosage ─────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Catégorie *'),
                          const SizedBox(height: 6),
                          // Point 17 : liste complète
                          DropdownButtonFormField<MedicationCategory>(
                            hint: const Text('Choisir une catégorie'),
                            initialValue: vm.formCategory,
                            isExpanded: true,
                            onChanged: vm.setFormCategory,
                            decoration: InputDecoration(
                              errorText: _submitted && vm.formCategory == null
                                  ? 'Champ requis'
                                  : null,
                            ),
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Dosage'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _dosageCtrl,
                            onChanged: vm.setFormDosage,
                            decoration: const InputDecoration(
                              hintText: 'Ex: 500mg, 1g, 2.5ml',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Date de péremption (mois + année) ─────────────────────
                _label('Date de péremption *'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Mois
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        hint: const Text('Mois'),
                        initialValue: vm.formMonth,
                        onChanged: vm.setFormMonth,
                        decoration: InputDecoration(
                          errorText: _submitted && vm.formMonth == null
                              ? 'Requis'
                              : null,
                        ),
                        items: List.generate(12, (i) {
                          const noms = [
                            'Janvier',
                            'Février',
                            'Mars',
                            'Avril',
                            'Mai',
                            'Juin',
                            'Juillet',
                            'Août',
                            'Septembre',
                            'Octobre',
                            'Novembre',
                            'Décembre',
                          ];
                          return DropdownMenuItem(
                            value: i + 1,
                            child: Text(noms[i]),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Année — Point 15 : max 5 ans
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        hint: const Text('Année'),
                        initialValue: vm.formYear,
                        onChanged: vm.setFormYear,
                        decoration: InputDecoration(
                          errorText: _submitted && vm.formYear == null
                              ? 'Requis'
                              : null,
                        ),
                        items: _availableYears
                            .map(
                              (y) => DropdownMenuItem(
                                value: y,
                                child: Text(y.toString()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'La date d\'expiration ne pourra plus être modifiée après ajout.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quantité + Seuil ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Quantité en stock'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _quantityCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (v) {
                                    vm.setFormQuantity(int.tryParse(v) ?? 0);
                                    setState(() {});
                                  },
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      vm.incrementQuantity();
                                      _quantityCtrl.text = vm.formQuantity
                                          .toString();
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      vm.decrementQuantity();
                                      _quantityCtrl.text = vm.formQuantity
                                          .toString();
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Seuil minimum'),
                          const SizedBox(height: 6),
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(hintText: '10'),
                            onChanged: (v) =>
                                vm.setFormMinThreshold(int.tryParse(v) ?? 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Numéro de lot + Prix ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Numéro de lot'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _lotCtrl,
                            onChanged: vm.setFormLotNumber,
                            decoration: const InputDecoration(
                              hintText: 'Ex: LOT-001',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Prix (Ar) — optionnel'),
                          const SizedBox(height: 6),
                          TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ex: 2500',
                            ),
                            onChanged: (v) =>
                                vm.setFormPrice(double.tryParse(v)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.stock),
                  child: const Text('ANNULER'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          setState(() => _submitted = true);
                          if (!_canSubmit(vm)) return;
                          vm.setFormName(_nameCtrl.text);
                          final ok = await vm.addMedication();
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
                      : const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'AJOUTER AU STOCK',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, StockViewModel vm) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: vm.nameSuggestions
              .map(
                (s) => ListTile(
                  title: Text(s, style: const TextStyle(fontSize: 14)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Existant',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  onTap: () {
                    _nameCtrl.text = s;
                    vm.setFormName(s);
                  },
                  dense: true,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Conseil",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Pour importer plusieurs médicaments à la fois, utilisez la fonction \"Importer fichier\" depuis la liste du stock.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
  );
}
