import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vonjiaina_front/presentation/viewmodels/rappel_viewmodel.dart';
import 'package:vonjiaina_front/presentation/screens/rappel/ajout_medicament_screen.dart';
import 'package:vonjiaina_front/presentation/screens/rappel/ajout_rappel_screen.dart';

class ListeRappelsScreen extends StatefulWidget {
  const ListeRappelsScreen({Key? key}) : super(key: key);
  
  @override
  _ListeRappelsScreenState createState() => _ListeRappelsScreenState();
}

class _ListeRappelsScreenState extends State<ListeRappelsScreen> {
  @override
void initState() {
  super.initState();

  Future.microtask(() {
    final viewModel = context.read<RappelViewModel>();
    viewModel.loadMedicaments();
    viewModel.loadRappels();
  });
}
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RappelViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Rappels Médicaments'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjoutMedicamentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: viewModel.isLoading && viewModel.medicaments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : viewModel.medicaments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun médicament ajouté',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Ajouter un médicament'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AjoutMedicamentScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.loadMedicaments();
                    await viewModel.loadRappels();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: viewModel.medicaments.length,
                    itemBuilder: (context, index) {
                      final medicament = viewModel.medicaments[index];
                      final rappels = viewModel.rappels
                          .where((r) => r.medicamentId == medicament.id)
                          .toList();
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: Icon(Icons.medical_services, color: Colors.blue),
                          title: Text(
                            medicament.nom,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${medicament.dosage} • ${rappels.length} rappel(s)'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteMedicamentDialog(context, medicament.id!);
                            },
                          ),
                          children: [
                            if (rappels.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Aucun rappel configuré',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ...rappels.map((rappel) => ListTile(
                                leading: Switch(
                                  value: rappel.isActive,
                                  onChanged: (value) {
                                    viewModel.toggleRappelActivation(rappel);
                                  },
                                ),
                                title: Text(
                                  '${rappel.heure.hour.toString().padLeft(2, '0')}:'
                                  '${rappel.heure.minute.toString().padLeft(2, '0')}',
                                ),
                                subtitle: Text(rappel.getJoursRepetitionText()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        // TODO: Écran d'édition
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteDialog(context, rappel.id!);
                                      },
                                    ),
                                  ],
                                ),
                              )).toList(),
                            
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.notifications_add, size: 18),
                                label: Text('Ajouter un rappel'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AjoutRappelScreen(
                                        medicamentId: medicament.id!,
                                        medicamentNom: medicament.nom,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, int rappelId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le rappel'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce rappel ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = Provider.of<RappelViewModel>(
                context, 
                listen: false
              );
              await viewModel.deleteRappel(rappelId);
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteMedicamentDialog(BuildContext context, int medicamentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le médicament'),
        content: Text('Tous les rappels associés seront également supprimés. Continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final viewModel = Provider.of<RappelViewModel>(
                context, 
                listen: false
              );
              await viewModel.deleteMedicament(medicamentId);
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}