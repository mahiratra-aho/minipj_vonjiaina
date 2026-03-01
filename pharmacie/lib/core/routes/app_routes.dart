import 'package:go_router/go_router.dart';
import '../../views/home/home_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_step1_view.dart';
import '../../views/auth/register_step2_view.dart';
import '../../views/auth/register_step3_view.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/stock/stock_list_view.dart';
import '../../views/stock/add_medication_view.dart';
import '../../views/stock/edit_medication_view.dart';
//import '../../views/stock/import_file_view.dart';
import '../../views/settings/settings_view.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String registerStep1 = '/register/step1';
  static const String registerStep2 = '/register/step2';
  static const String registerStep3 = '/register/step3';
  static const String dashboard = '/dashboard';
  static const String stock = '/stock';
  static const String addMedication = '/stock/add';
  static const String editMedication = '/stock/edit/:id';
  static const String importFile = '/stock/import';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (_, _) => const HomeView()),
      GoRoute(path: login, builder: (_, _) => const LoginView()),
      GoRoute(
        path: registerStep1,
        builder: (_, _) => const RegisterStep1View(),
      ),
      GoRoute(
        path: registerStep2,
        builder: (_, _) => const RegisterStep2View(),
      ),
      GoRoute(
        path: registerStep3,
        builder: (_, _) => const RegisterStep3View(),
      ),
      GoRoute(path: dashboard, builder: (_, _) => const DashboardView()),
      GoRoute(path: stock, builder: (_, _) => const StockListView()),
      GoRoute(
        path: addMedication,
        builder: (_, _) => const AddMedicationView(),
      ),
      GoRoute(
        path: '/stock/edit/:id',
        builder: (_, state) =>
            EditMedicationView(medicationId: state.pathParameters['id'] ?? ''),
      ),
      // GoRoute(path: importFile, builder: (_, _) => const ImportFileView()),
      GoRoute(path: settings, builder: (_, _) => const SettingsView()),
    ],
  );
}
