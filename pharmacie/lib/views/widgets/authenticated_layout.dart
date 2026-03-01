import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'app_sidebar.dart';

class AuthenticatedLayout extends StatelessWidget {
  final String currentRoute;
  final PreferredSizeWidget? appBar;
  final Widget child;

  const AuthenticatedLayout({
    super.key,
    required this.currentRoute,
    this.appBar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(currentRoute: currentRoute),
          const VerticalDivider(width: 1, color: AppColors.divider),
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: appBar,
              body: child,
            ),
          ),
        ],
      ),
    );
  }
}
