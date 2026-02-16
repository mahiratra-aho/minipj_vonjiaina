import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/health_models.dart';
import '../../../presentation/viewmodels/health_viewmodel.dart' as health;

class EtatSanteScreen extends StatefulWidget {
  const EtatSanteScreen({super.key});

  @override
  State<EtatSanteScreen> createState() => _EtatSanteScreenState();
}

class _EtatSanteScreenState extends State<EtatSanteScreen> {
  late HealthViewModel _healthViewModel;

  @override
  void initState() {
    super.initState();
    _healthViewModel = Provider.of<HealthViewModel>(context, listen: false);
    _healthViewModel.loadEtatsSante();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<health.HealthViewModel>(
      builder: (context, healthViewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'État de Santé',
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
              : healthViewModel.etatsSante.isEmpty
                  ? _buildEmptyState()
                  : _buildEtatsSanteList(),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddEtatSanteDialog,
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
            Icons.favorite,
            size: 80,
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun état de santé',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier état de santé',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtatsSanteList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: healthViewModel.etatsSante.length,
      itemBuilder: (context, index) {
        final etat = healthViewModel.etatsSante[index];
        return _buildEtatSanteCard(etat);
      },
    );
  }

  Widget _buildEtatSanteCard(EtatSante etat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: etat.humeur.color.withValues(alpha: 0.1),
          child: Text(
            etat.humeur.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          etat.humeur.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${etat.formattedDate} • ${etat.formattedTime}',
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
              onPressed: () => _showEditEtatSanteDialog(etat),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEtatSante(etat.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEtatSanteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEtatSanteDialog(
        onSaved: (etat) async {
          final success = await _healthViewModel.addEtatSante(etat);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('État de santé ajouté avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditEtatSanteDialog(EtatSante etat) {
    showDialog(
      context: context,
      builder: (context) => AddEtatSanteDialog(
        existingEtat: etat,
        onSaved: (etat) async {
          final success = await _healthViewModel.updateEtatSante(etat);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('État de santé mis à jour avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteEtatSante(String etatId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet état de santé ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _healthViewModel.deleteEtatSante(etatId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('État de santé supprimé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class AddEtatSanteDialog extends StatefulWidget {
  final Function(EtatSante) onSaved;
  final EtatSante? existingEtat;

  const AddEtatSanteDialog({
    super.key,
    required this.onSaved,
    this.existingEtat,
  });

  @override
  State<AddEtatSanteDialog> createState() => _AddEtatSanteDialogState();
}

class _AddEtatSanteDialogState extends State<AddEtatSanteDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController notesController = TextEditingController();
  Humeur humeurSelectionnee = Humeur.neutre;

  @override
  void initState() {
    super.initState();
    if (widget.existingEtat != null) {
      humeurSelectionnee = widget.existingEtat!.humeur;
      notesController.text = widget.existingEtat!.notes ?? '';
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
              'Comment vous sentez-vous ?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Humeur.values.map((humeur) {
                  return GestureDetector(
                    onTap: () => setState(() => humeurSelectionnee = humeur),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: humeurSelectionnee == humeur
                            ? humeur.color.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: humeurSelectionnee == humeur
                              ? humeur.color
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            humeur.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            humeur.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: humeur.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
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
                  onPressed: _saveEtatSante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.existingEtat != null ? 'Ajouter' : 'Modifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEtatSante() async {
    if (formKey.currentState!.validate()) {
      final etat = EtatSante(
        id: widget.existingEtat?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        humeur: humeurSelectionnee,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        date: widget.existingEtat?.date ?? DateTime.now(),
      );

      widget.onSaved(etat);
      Navigator.of(context).pop();
    }
  }
}
