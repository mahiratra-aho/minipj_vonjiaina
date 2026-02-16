import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/health_models.dart';
import '../../../presentation/viewmodels/health_viewmodel.dart' as health;

class RappelsScreen extends StatefulWidget {
  const RappelsScreen({super.key});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  late HealthViewModel _healthViewModel;

  @override
  void initState() {
    super.initState();
    _healthViewModel = Provider.of<health.HealthViewModel>(context, listen: false);
    _healthViewModel.loadRappels();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<health.HealthViewModel>(
      builder: (context, healthViewModel, child) {
        _healthViewModel = healthViewModel;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Rappels Médicaments',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            centerTitle: true,
          ),
          body: healthViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : healthViewModel.rappels.isEmpty
                  ? _buildEmptyState()
                  : _buildRappelsList(),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddRappelDialog,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 80,
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun rappel',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier rappel de médicament',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRappelsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: healthViewModel.rappels.length,
      itemBuilder: (context, index) {
        final rappel = healthViewModel.rappels[index];
        return _buildRappelCard(rappel);
      },
    );
  }

  Widget _buildRappelCard(MedicamentRappel rappel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
          child: Icon(
            Icons.medication,
            color: AppColors.primaryLight,
          ),
        ),
        title: Text(
          rappel.nomMedicament,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${rappel.formattedHeure} • ${rappel.formattedDate}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryLight),
              onPressed: () => _showEditRappelDialog(rappel),
            ),
            Switch(
              value: rappel.isActive,
              onChanged: (value) => _healthViewModel.toggleRappel(rappel.id),
              activeThumbColor: AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRappelDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRappelDialog(
        onSaved: (rappel) async {
          final success = await _healthViewModel.addRappel(rappel);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Rappel ajouté avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditRappelDialog(MedicamentRappel rappel) {
    showDialog(
      context: context,
      builder: (context) => AddRappelDialog(
        existingRappel: rappel,
        onSaved: (rappel) async {
          final success = await _healthViewModel.updateRappel(rappel);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Rappel mis à jour avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }
}

class AddRappelDialog extends StatefulWidget {
  final Function(MedicamentRappel) onSaved;
  final MedicamentRappel? existingRappel;

  const AddRappelDialog({
    super.key,
    required this.onSaved,
    this.existingRappel,
  });

  @override
  State<AddRappelDialog> createState() => _AddRappelDialogState();
}

class _AddRappelDialogState extends State<AddRappelDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  TimeOfDay heure = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.existingRappel != null) {
      nomController.text = widget.existingRappel!.nomMedicament;
      notesController.text = widget.existingRappel!.notes ?? '';
      heure = widget.existingRappel!.heure;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 16 : 24),
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width < 400
              ? MediaQuery.of(context).size.width * 0.9
              : 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nouveau rappel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom du médicament',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.medication),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom de médicament';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Heure de prise'),
                    subtitle: Text(heure.format(context)),
                    trailing: TextButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: heure,
                        );
                        if (time != null) {
                          heure = time;
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: const Text('Choisir'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveRappel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.existingRappel != null ? 'Ajouter' : 'Modifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRappel() async {
    if (formKey.currentState!.validate()) {
      final rappel = MedicamentRappel(
        id: widget.existingRappel?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nomMedicament: nomController.text.trim(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        heure: heure,
        isActive: true,
        dateCreation: widget.existingRappel?.dateCreation ?? DateTime.now(),
      );

      widget.onSaved(rappel);
      Navigator.of(context).pop();
    }
}
