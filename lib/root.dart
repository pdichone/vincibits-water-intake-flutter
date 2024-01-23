import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/screens/auth_screen.dart';
import 'package:water_intake/widgets/custom_drawer.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderr>(
      builder: (context, authProvider, child) {
        User? user = authProvider.user;
        if (user == null) {
          return const AuthScreen();
        }
        return CustomDrawer();
      },
    );
  }
}
