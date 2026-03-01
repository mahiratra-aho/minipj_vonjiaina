// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/routes/app_routes.dart';
// import '../../services/file_service.dart';
// import '../../viewmodels/stock_viewmodel.dart';
// import '../widgets/authenticated_layout.dart';

// class ImportFileView extends StatefulWidget {
//   const ImportFileView({super.key});

//   @override
//   State<ImportFileView> createState() => _ImportFileViewState();
// }

// class _ImportFileViewState extends State<ImportFileView> {
//   bool _isDragging = false;
//   String? _selectedFileName;
//   bool _isImporting = false;

//   @override
//   Widget build(BuildContext context) {
//     return AuthenticatedLayout(
//       currentRoute: AppRoutes.stock,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildBreadcrumb(context),
//             const SizedBox(height: 12),
//             Text(
//               'Importation de produits en masse',
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 28),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Mettez à jour votre inventaire rapidement via un fichier Excel ou CSV.',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 28),

//             Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 700),
//                 child: Column(
//                   children: [
//                     _buildFormatSection(context),
//                     const SizedBox(height: 20),
//                     _buildUploadSection(context),
//                     const SizedBox(height: 20),
//                     _buildInfoBanner(context),
//                     const SizedBox(height: 24),
//                     _buildActions(context),
//                     const SizedBox(height: 24),
//                     Text(
//                       '© 2024 Vonjiaina Pharmacist Space - Gestion de Stock Avancée',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodyMedium?.copyWith(fontSize: 11),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBreadcrumb(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTap: () => context.go(AppRoutes.stock),
//           child: const Text(
//             '← Stock',
//             style: TextStyle(
//               color: AppColors.primary,
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         const Text(
//           ' / Importation par fichier',
//           style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Widget _buildFormatSection(BuildContext context) {
//     const columns = [
//       (
//         'Nom du produit',
//         'Texte',
//         true,
//         'Le nom complet du médicament ou matériel.',
//       ),
//       (
//         'Code CIP',
//         'Nombre/ID',
//         true,
//         'Identifiant unique du produit (clé de mise à jour).',
//       ),
//       ("Prix d'achat", 'Décimal', true, 'Prix unitaire payé au fournisseur.'),
//       ('Prix de vente', 'Décimal', true, 'Prix de vente public conseillé.'),
//       (
//         'Stock initial',
//         'Entier',
//         false,
//         "Quantité en stock au moment de l'import.",
//       ),
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: Text(
//                       '1',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Formats supportés et structure',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.headlineMedium?.copyWith(fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 RichText(
//                   text: const TextSpan(
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textPrimary,
//                     ),
//                     children: [
//                       TextSpan(text: 'Veuillez utiliser un fichier au format '),
//                       TextSpan(
//                         text: '.CSV',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       TextSpan(text: ' ou '),
//                       TextSpan(
//                         text: '.XLSX',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.success,
//                         ),
//                       ),
//                       TextSpan(
//                         text:
//                             '. Assurez-vous que les colonnes correspondent exactement aux noms ci-dessous.',
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Table
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.cardBorder),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       // Header
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         decoration: const BoxDecoration(
//                           color: AppColors.background,
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(8),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'COLONNE',
//                                 style: Theme.of(context).textTheme.labelSmall
//                                     ?.copyWith(color: AppColors.primary),
//                               ),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 'TYPE DE DONNÉE',
//                                 style: Theme.of(context).textTheme.labelSmall
//                                     ?.copyWith(color: AppColors.primary),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 80,
//                               child: Text(
//                                 'REQUIS',
//                                 style: Theme.of(context).textTheme.labelSmall
//                                     ?.copyWith(color: AppColors.primary),
//                               ),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 'DESCRIPTION',
//                                 style: Theme.of(context).textTheme.labelSmall
//                                     ?.copyWith(color: AppColors.primary),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       ...columns.asMap().entries.map((e) {
//                         final col = e.value;
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             border: e.key < columns.length - 1
//                                 ? const Border(
//                                     top: BorderSide(color: AppColors.divider),
//                                   )
//                                 : null,
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   col.$1,
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   col.$2,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: AppColors.textSecondary,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 80,
//                                 child: Text(
//                                   col.$3 ? 'Oui' : 'Optionnel',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: col.$3
//                                         ? AppColors.success
//                                         : AppColors.textMuted,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   col.$4,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: AppColors.textSecondary,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Download template
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: AppColors.background,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: AppColors.cardBorder),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.description_outlined,
//                         color: AppColors.textSecondary,
//                         size: 22,
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Besoin d'aide ?",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               'Téléchargez notre modèle pour éviter les erreurs de format.',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.textMuted,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       OutlinedButton.icon(
//                         onPressed: () => _downloadTemplate('csv'),
//                         icon: const Icon(Icons.download, size: 16),
//                         label: const Text(
//                           'TÉLÉCHARGER CSV',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       OutlinedButton.icon(
//                         onPressed: () => _downloadTemplate('excel'),
//                         icon: const Icon(Icons.download, size: 16),
//                         label: const Text(
//                           'TÉLÉCHARGER EXCEL',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUploadSection(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.cardBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: const BoxDecoration(
//                     color: AppColors.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: Text(
//                       '2',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Sélectionnez votre fichier',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.headlineMedium?.copyWith(fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//             child: DragTarget<Object>(
//               onWillAcceptWithDetails: (_) {
//                 setState(() => _isDragging = true);
//                 return true;
//               },
//               onLeave: (_) => setState(() => _isDragging = false),
//               onAcceptWithDetails: (_) {
//                 setState(() {
//                   _isDragging = false;
//                   _selectedFileName = 'fichier_import.csv';
//                 });
//               },
//               builder: (context, candidateData, rejectedData) {
//                 return GestureDetector(
//                   onTap: _pickFile,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(vertical: 40),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: _isDragging
//                             ? AppColors.primary
//                             : AppColors.cardBorder,
//                         width: _isDragging ? 2 : 1,
//                         style: BorderStyle.solid,
//                       ),
//                       color: _isDragging
//                           ? AppColors.primarySurface
//                           : AppColors.background,
//                     ),
//                     child: Center(
//                       child: _selectedFileName != null
//                           ? _buildSelectedFile()
//                           : _buildDropZoneContent(context),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropZoneContent(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             border: Border.all(color: AppColors.cardBorder),
//           ),
//           child: const Icon(
//             Icons.upload_file_outlined,
//             size: 28,
//             color: AppColors.textMuted,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Glissez-déposez votre fichier ici',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'ou parcourez vos dossiers locaux',
//           style: TextStyle(fontSize: 13, color: AppColors.textMuted),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: _pickFile,
//           child: const Text(
//             'CHOISIR UN FICHIER',
//             style: TextStyle(fontWeight: FontWeight.w700),
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'MAX. 10MB • CSV, XLSX',
//           style: TextStyle(
//             fontSize: 11,
//             color: AppColors.textMuted,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSelectedFile() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: AppColors.successLight,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.check_circle, color: AppColors.success),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               _selectedFileName!,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const Text(
//               'Prêt à importer',
//               style: TextStyle(color: AppColors.success, fontSize: 12),
//             ),
//           ],
//         ),
//         const SizedBox(width: 12),
//         IconButton(
//           icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
//           onPressed: () => setState(() => _selectedFileName = null),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoBanner(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFBEB),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'INFORMATION IMPORTANTE SUR LA MISE À JOUR',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 12,
//                     color: AppColors.warning,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Si un produit importé existe déjà dans votre base de données (basé sur le Code CIP), ses informations (prix, stock) seront automatiquement mises à jour avec les nouvelles valeurs fournies dans votre fichier.",
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     fontSize: 13,
//                     color: const Color(0xFF92400E),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActions(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         OutlinedButton(
//           onPressed: () => context.go(AppRoutes.stock),
//           child: const Text('ANNULER'),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton.icon(
//           onPressed: _selectedFileName == null ? null : _importFile,
//           icon: _isImporting
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Icon(Icons.upload, size: 18),
//           label: const Text(
//             'IMPORTER LE FICHIER',
//             style: TextStyle(fontWeight: FontWeight.w700),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _downloadTemplate(String format) async {
//     try {
//       if (format == 'csv') {
//         await FileService.downloadCSVTemplate();
//       } else {
//         await FileService.downloadExcelTemplate();
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Modèle $format téléchargé avec succès'),
//             backgroundColor: AppColors.success,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur lors du téléchargement: $e'),
//             backgroundColor: AppColors.danger,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['csv', 'xlsx'],
//       );

//       if (result != null) {
//         setState(() => _selectedFileName = result.files.single.name);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur lors de la sélection du fichier: $e'),
//             backgroundColor: AppColors.danger,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _importFile() async {
//     setState(() => _isImporting = true);

//     try {
//       final medications = await FileService.importFromFile();

//       if (medications.isNotEmpty) {
//         if (!mounted) return;

//         final vm = Provider.of<StockViewModel>(context, listen: false);
//         final success = await vm.importMedications(medications);

//         if (success && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Importation réussie ! ${medications.length} médicaments importés.',
//               ),
//               backgroundColor: AppColors.success,
//             ),
//           );
//           context.go(AppRoutes.stock);
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Aucun médicament valide trouvé dans le fichier.'),
//               backgroundColor: AppColors.warning,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur lors de l\'importation: $e'),
//             backgroundColor: AppColors.danger,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isImporting = false);
//       }
//     }
//   }
// }
