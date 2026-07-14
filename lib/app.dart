import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/cycle_repository.dart';
import 'presentation/providers/cycle_provider.dart';
import 'presentation/splash/splash_screen.dart';

/// Root widget: sets up dependency injection (repository -> provider)
/// and the app-wide theme, then hands off to [SplashScreen].
class MoodlyApp extends StatelessWidget {
  const MoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CycleRepository>(create: (_) => LocalCycleRepository()),
        ChangeNotifierProvider<CycleProvider>(
          create: (context) => CycleProvider(context.read<CycleRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Moodly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
