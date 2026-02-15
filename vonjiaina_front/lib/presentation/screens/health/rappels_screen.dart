import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/health_service.dart';
import '../../../data/models/health_models.dart';

class RappelsScreen extends StatefulWidget {
  const RappelsScreen({super.key});

  @override
  State<RappelsScreen> createState() => _RappelsScreenState();
}

class _RappelsScreenState extends State<RappelsScreen> {
  final HealthService _healthService = HealthService();
  List<MedicamentRappel> _rappels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRappels();
  }

  Future<void> _loadRappels() async {
    setState(() => _isLoading = true);

    try {
      final rappels = await _healthService.getRappels();
      setState(() {
        _rappels = rappels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rappels.isEmpty
              ? _buildEmptyState()
              : _buildRappelsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRappelDialog,
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
      itemCount: _rappels.length,
      itemBuilder: (context, index) {
        final rappel = _rappels[index];
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
              onChanged: (value) => _toggleRappel(rappel.id),
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
          final success = await _healthService.addRappel(rappel);
          if (success) {
            _loadRappels();
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
          final success = await _healthService.updateRappel(rappel);
          if (success) {
            _loadRappels();
          }
        },
      ),
    );
  }

  Future<void> _toggleRappel(String rappelId) async {
    final success = await _healthService.toggleRappel(rappelId);
    if (success) {
      _loadRappels();
    }
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
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _notesController = TextEditingController();
  TimeOfDay _heure = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.existingRappel != null) {
      _nomController.text = widget.existingRappel!.nomMedicament;
      _notesController.text = widget.existingRappel!.notes ?? '';
      _heure = widget.existingRappel!.heure;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding:
            EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 16 : 24),
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
            Text(
              widget.existingRappel != null
                  ? 'Modifier le rappel'
                  : 'Nouveau rappel',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomController,
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
                    controller: _notesController,
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
                    subtitle: Text(_heure.format(context)),
                    trailing: TextButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _heure,
                        );
                        if (time != null) {
                          setState(() => _heure = time);
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                      widget.existingRappel != null ? 'Modifier' : 'Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRappel() async {
    if (_formKey.currentState!.validate()) {
      final rappel = MedicamentRappel(
        id: widget.existingRappel?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        nomMedicament: _nomController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        heure: _heure,
        isActive: true,
        dateCreation: widget.existingRappel?.dateCreation ?? DateTime.now(),
      );

      widget.onSaved(rappel);
      Navigator.of(context).pop();
    }
  }
}
