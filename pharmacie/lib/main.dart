import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/stock_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  runApp(const VonjiainaApp());
}

class VonjiainaApp extends StatelessWidget {
  const VonjiainaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StockViewModel()),
        ChangeNotifierProxyProvider<StockViewModel, DashboardViewModel>(
          create: (ctx) =>
              DashboardViewModel(ctx.read<StockViewModel>().allMedications),
          update: (ctx, stock, prev) =>
              DashboardViewModel(stock.allMedications),
        ),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Vonjiaina - Portail Pharmacie',
        theme: AppTheme.theme,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
