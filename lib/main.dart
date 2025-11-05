import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/datasources/mood_local_datasource.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  await MoodLocalDataSourceImpl.instance.init();

  runApp(const ProviderScope(child: MoodDotApp()));
}
