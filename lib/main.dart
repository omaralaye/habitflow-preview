import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../core/app_settings.dart';
import '../core/challenge_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://qcpaeqtoxxkqfjlfkepa.supabase.co',
      anonKey: 'sb_publishable_k7iF_2P7dtitpuE0eyA-Gw_RioZ2u0R',
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  await AppSettings.load();
  await ChallengeManager.load();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppSettings.themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppSettings.themeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'HabitFlow',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettings.themeModeNotifier.value,
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}
