import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/services/api_service.dart';
import 'core/services/location_service.dart';
import 'data/repositories/pharmacie_repository.dart';
import 'presentation/viewmodels/search_viewmodel.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser les services
    final apiService = ApiService();
    final locationService = LocationService();
    final pharmacieRepository = PharmacieRepository(apiService: apiService);

    return MultiProvider(
      providers: [
        // ViewModel avec injection de dépendances (MVVM)
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            repository: pharmacieRepository,
            locationService: locationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'VonjiAIna',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primaryDark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryLight,
            primary: AppColors.primaryLight,
            secondary: AppColors.accentTeal,
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,

          // AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.primaryDark),
            titleTextStyle: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Card Theme
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
