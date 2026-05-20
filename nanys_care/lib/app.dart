import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/caregiver_list_provider.dart';
import 'providers/profile_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class NanysCareApp extends StatelessWidget {
  const NanysCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CaregiverListProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      builder: (context, _) {
        final auth = context.watch<AuthProvider>();
        return MaterialApp.router(
          title: 'Nanys Care',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.build(auth),
        );
      },
    );
  }
}
