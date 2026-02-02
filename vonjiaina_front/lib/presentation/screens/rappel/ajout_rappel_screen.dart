import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/rappel_viewmodel.dart';

class AjoutRappelScreen extends StatefulWidget {
  final int medicamentId;
  final String medicamentNom;
  
  const AjoutRappelScreen({
    Key? key,
    required this.medicamentId,
    required this.medicamentNom,
  }) : super(key: key);
  
  @override
  _AjoutRappelScreenState createState() => _AjoutRappelScreenState();
}

class _AjoutRappelScreenState extends State<AjoutRappelScreen> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 18, minute: 0);
  final List<bool> _selectedDays = List.filled(7, true);
  final TextEditingController _messageController = TextEditingController();
  
  final List<String> _joursSemaine = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un rappel'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.blue),
                title: Text('Médicament'),
                subtitle: Text(widget.medicamentNom),
              ),
            ),
            SizedBox(height: 24),
            
            // Sélection de l'heure
            Card(
              child: ListTile(
                title: Text('Heure du rappel'),
                subtitle: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
                ),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            
            // Jours de répétition
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répéter les jours:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        return FilterChip(
                          label: Text(_joursSemaine[index]),
                          selected: _selectedDays[index],
                          onSelected: (selected) {
                            setState(() {
                              _selectedDays[index] = selected;
                            });
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Message personnalisé
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message personnalisé (optionnel)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ex: N\'oublie pas ton médicament !',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            
            // Bouton d'ajout
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.notifications_add),
                label: Text('Ajouter le rappel'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  final joursActifs = <int>[];
                  for (int i = 0; i < _selectedDays.length; i++) {
                    if (_selectedDays[i]) {
                      joursActifs.add(i + 1);
                    }
                  }
                  
                  if (joursActifs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sélectionnez au moins un jour'))
                    );
                    return;
                  }
                  
                  final viewModel = Provider.of<RappelViewModel>(
                    context, 
                    listen: false
                  );
                  
                  await viewModel.addRappel(
                    medicamentId: widget.medicamentId,
                    heure: _selectedTime,
                    joursRepetition: joursActifs,
                    messagePersonnalise: _messageController.text.isNotEmpty
                        ? _messageController.text
                        : null,
                  );
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rappel ajouté avec succès'))
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}