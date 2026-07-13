import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:orbit_notes/app.dart';
import 'package:orbit_notes/core/config/supabase_config.dart';
import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await AppPrefs.open();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await configureDependencies(prefs: prefs);
  getIt<AuthBloc>().add(const AuthStarted());

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.light.canvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const OrbitApp());
  FlutterNativeSplash.remove();
}
