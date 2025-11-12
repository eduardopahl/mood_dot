import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/datasources/mood_local_datasource.dart';
import 'core/services/admob_service.dart';
import 'core/services/premium_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  await initializeDateFormatting(locale.toString(), null);

  await MoodLocalDataSourceImpl.instance.init();

  // Inicializar serviços de premium e ads
  await PremiumService.instance.init();
  await AdMobService.initialize();

  runApp(const ProviderScope(child: MoodDotApp()));
}
