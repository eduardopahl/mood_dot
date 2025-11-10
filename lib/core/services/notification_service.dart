import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../../domain/repositories/mood_repository.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService getInstance(MoodRepository repository) {
    _instance ??= NotificationService._internal(repository);
    return _instance!;
  }

  NotificationService._internal(this._moodRepository);

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final MoodRepository _moodRepository;

  // Chaves para SharedPreferences
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _lastNotificationKey = 'last_notification_date';
  static const String _userEngagementKey = 'user_engagement_score';
  static const String _preferredTimeKey = 'preferred_notification_time';

  bool _initialized = false;

  /// Inicializa o serviço de notificações (versão real)
  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🚀 Inicializando serviço real de notificações...');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final result = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = result ?? false;
    debugPrint('✅ Serviço de notificações inicializado: $_initialized');
  }

  /// Callback quando usuário toca na notificação
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notificação tocada - abrindo app para registrar humor');
    // Aqui você pode navegar diretamente para a tela de registro de humor
    // Por exemplo: Navigator.pushNamed(context, '/add_mood');
  }

  /// Solicita permissão para notificações (real)
  Future<bool> requestPermission() async {
    debugPrint('🔐 Solicitando permissões reais de notificação...');

    if (Platform.isAndroid) {
      final androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Para Android 13+ precisa de permissão de notificação
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      debugPrint('🤖 Android - Permissão concedida: $granted');
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🍎 iOS - Permissão concedida: $granted');
      return granted ?? false;
    }

    return true; // Para outras plataformas
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_reminderEnabledKey) ?? false;
    debugPrint('Notificações habilitadas: $enabled');
    return enabled;
  }

  /// Habilita ou desabilita lembretes
  Future<void> setRemindersEnabled(bool enabled) async {
    debugPrint('Alterando estado dos lembretes para: $enabled');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);

    if (enabled) {
      // Switch LIGADO: agenda notificações diárias
      await _scheduleReminder();
    } else {
      // Switch DESLIGADO: cancela todas as notificações - nenhuma será enviada
      await cancelAllReminders();
    }

    debugPrint('Estado dos lembretes alterado com sucesso');
  }

  /// Agenda o próximo lembrete de forma inteligente
  Future<void> _scheduleReminder() async {
    debugPrint('🧠 Iniciando lógica inteligente de notificações...');

    // 1. Verifica se já registrou humor hoje
    if (await _hasRegisteredTodaysMood()) {
      debugPrint('✅ Usuário já registrou humor hoje - pulando notificação');
      return;
    }

    // 2. Analisa o melhor horário baseado no histórico
    final optimalTime = await _getOptimalNotificationTime();
    debugPrint(
      '⏰ Horário ótimo calculado: ${optimalTime.hour}:${optimalTime.minute}',
    );

    // 3. Verifica o nível de engajamento do usuário
    final engagementScore = await _getUserEngagementScore();
    debugPrint('📊 Score de engajamento: $engagementScore');

    // 4. Ajusta a estratégia baseada no engajamento
    if (engagementScore < 0.3) {
      // Usuário pouco engajado - notificações mais espaçadas e horários flexíveis
      await _scheduleGentleReminder(optimalTime);
    } else if (engagementScore > 0.7) {
      // Usuário muito engajado - pode ter notificações mais frequentes
      await _scheduleActiveReminder(optimalTime);
    } else {
      // Usuário moderadamente engajado - estratégia padrão
      await _scheduleStandardReminder(optimalTime);
    }

    debugPrint('🎯 Lembrete inteligente agendado com sucesso');
  }

  /// Verifica se o usuário já registrou humor hoje baseado nos dados reais
  Future<bool> _hasRegisteredTodaysMood() async {
    try {
      debugPrint('🔍 Verificando se já registrou humor hoje...');

      // Busca todos os mood entries de hoje
      final allEntries = await _moodRepository.getAllMoodEntries();
      final today = DateTime.now();

      // Filtra entries de hoje
      final todayEntries =
          allEntries.where((entry) {
            final entryDate = entry.date;
            return entryDate.year == today.year &&
                entryDate.month == today.month &&
                entryDate.day == today.day;
          }).toList();

      final hasRegisteredToday = todayEntries.isNotEmpty;
      debugPrint(
        '📊 Entries hoje: ${todayEntries.length} - Já registrou: $hasRegisteredToday',
      );

      return hasRegisteredToday;
    } catch (e) {
      debugPrint('❌ Erro ao verificar mood entries: $e');
      // Em caso de erro, assume que não registrou (fallback)
      return false;
    }
  }

  /// Calcula o horário ótimo baseado no histórico real do usuário
  Future<TimeOfDay> _getOptimalNotificationTime() async {
    try {
      debugPrint('⏰ Calculando horário ótimo baseado em dados reais...');

      final prefs = await SharedPreferences.getInstance();

      // Primeiro verifica se há um horário preferido salvo
      final savedTime = prefs.getInt(_preferredTimeKey);
      if (savedTime != null) {
        final hour = savedTime ~/ 100;
        final minute = savedTime % 100;
        debugPrint('💾 Usando horário preferido salvo: ${hour}:${minute}');
        return TimeOfDay(hour: hour, minute: minute);
      }

      // Analisa padrões do histórico de mood entries
      final allEntries = await _moodRepository.getAllMoodEntries();

      if (allEntries.length >= 5) {
        // Se tem pelo menos 5 registros, analisa padrões
        final hourCounts = <int, int>{};

        for (final entry in allEntries.take(30)) {
          // Últimos 30 registros
          final hour = entry.createdAt.hour;
          hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
        }

        // Encontra o horário mais comum
        int mostCommonHour = 20; // Padrão
        int maxCount = 0;

        hourCounts.forEach((hour, count) {
          if (count > maxCount) {
            maxCount = count;
            mostCommonHour = hour;
          }
        });

        // Agenda 2 horas antes do horário mais comum de registro
        int optimalHour = mostCommonHour - 2;
        if (optimalHour < 8) optimalHour = 8;
        if (optimalHour > 22) optimalHour = 20;

        debugPrint('📈 Horário mais comum de registro: ${mostCommonHour}h');
        debugPrint('🎯 Horário ótimo calculado: ${optimalHour}:00');

        return TimeOfDay(hour: optimalHour, minute: 0);
      }

      // Se não há histórico suficiente, usa análise baseada no horário atual
      final now = DateTime.now();

      if (now.hour < 12) {
        // Manhã: agenda para o final da tarde
        return const TimeOfDay(hour: 18, minute: 30);
      } else if (now.hour < 18) {
        // Tarde: agenda para a noite
        return const TimeOfDay(hour: 20, minute: 0);
      } else {
        // Noite: agenda para o próximo dia de manhã
        return const TimeOfDay(hour: 9, minute: 0);
      }
    } catch (e) {
      debugPrint('❌ Erro ao calcular horário ótimo: $e');
      // Fallback para horário padrão
      return const TimeOfDay(hour: 20, minute: 0);
    }
  }

  /// Calcula o score de engajamento baseado em dados reais (0.0 a 1.0)
  Future<double> _getUserEngagementScore() async {
    try {
      debugPrint(
        '📊 Calculando score de engajamento baseado em dados reais...',
      );

      final prefs = await SharedPreferences.getInstance();
      final allEntries = await _moodRepository.getAllMoodEntries();

      if (allEntries.isEmpty) {
        debugPrint('📊 Nenhum entry encontrado - score inicial: 0.1');
        return 0.1; // Usuário novo
      }

      double totalScore = 0.0;
      int factors = 0;

      // 1. Frequência de registro (últimos 30 dias)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentEntries =
          allEntries
              .where((entry) => entry.createdAt.isAfter(thirtyDaysAgo))
              .toList();

      double frequencyScore = (recentEntries.length / 30.0).clamp(0.0, 1.0);
      totalScore += frequencyScore;
      factors++;
      debugPrint(
        '📈 Frequência (30 dias): ${recentEntries.length}/30 = $frequencyScore',
      );

      // 2. Consistência (quantos dias únicos tem registro nos últimos 14 dias)
      final fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));
      final recent14Days = allEntries.where(
        (entry) => entry.createdAt.isAfter(fourteenDaysAgo),
      );

      final uniqueDays = <String>{};
      for (final entry in recent14Days) {
        final dayKey =
            '${entry.date.year}-${entry.date.month}-${entry.date.day}';
        uniqueDays.add(dayKey);
      }

      double consistencyScore = (uniqueDays.length / 14.0).clamp(0.0, 1.0);
      totalScore += consistencyScore;
      factors++;
      debugPrint(
        '📅 Consistência (14 dias): ${uniqueDays.length}/14 = $consistencyScore',
      );

      // 3. Tempo de uso (quantos meses desde primeiro registro)
      if (allEntries.isNotEmpty) {
        final firstEntry = allEntries.last; // Assumindo que está ordenado
        final monthsUsing =
            DateTime.now().difference(firstEntry.createdAt).inDays / 30;
        double longevityScore = (monthsUsing / 6.0).clamp(
          0.0,
          1.0,
        ); // 6 meses = score máximo
        totalScore += longevityScore;
        factors++;
        debugPrint(
          '⏳ Tempo de uso: ${monthsUsing.toStringAsFixed(1)} meses = $longevityScore',
        );
      }

      // 4. Variedade de humores (diversidade emocional)
      final uniqueMoods = allEntries.map((e) => e.moodLevel).toSet();
      double varietyScore = (uniqueMoods.length / 10.0).clamp(
        0.0,
        1.0,
      ); // 10 níveis máximo
      totalScore += varietyScore;
      factors++;
      debugPrint(
        '🎭 Variedade de humores: ${uniqueMoods.length}/10 = $varietyScore',
      );

      // 5. Uso de notas (engajamento qualitativo)
      final entriesWithNotes =
          allEntries
              .where(
                (entry) => entry.note != null && entry.note!.trim().isNotEmpty,
              )
              .length;
      double notesScore = (entriesWithNotes / allEntries.length).clamp(
        0.0,
        1.0,
      );
      totalScore += notesScore;
      factors++;
      debugPrint(
        '📝 Uso de notas: $entriesWithNotes/${allEntries.length} = $notesScore',
      );

      final finalScore =
          factors > 0 ? (totalScore / factors).clamp(0.0, 1.0) : 0.1;

      // Salva o score calculado
      await prefs.setDouble(_userEngagementKey, finalScore);

      debugPrint(
        '🎯 Score final de engajamento: ${finalScore.toStringAsFixed(2)}',
      );
      return finalScore;
    } catch (e) {
      debugPrint('❌ Erro ao calcular engajamento: $e');
      // Fallback para score padrão
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_userEngagementKey) ?? 0.5;
    }
  }

  /// Estratégia para usuários pouco engajados
  Future<void> _scheduleGentleReminder(TimeOfDay time) async {
    debugPrint('😊 Aplicando estratégia gentil - usuário pouco engajado');

    await cancelAllReminders();

    const androidDetails = AndroidNotificationDetails(
      'gentle_reminder',
      'Lembretes Gentis',
      channelDescription: 'Lembretes suaves para usuários menos ativos',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'gentle_reminder',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mensagens mais suaves
    final messages = [
      'Como você está se sentindo hoje? 😊',
      'Que tal compartilhar seu humor? 💭',
      'Um minutinho para refletir sobre seu dia? 🌟',
    ];

    final message = messages[DateTime.now().day % messages.length];

    await _notifications.periodicallyShow(
      1,
      'MoodDot 💙',
      message,
      RepeatInterval.daily,
      details,
    );

    debugPrint('😊 Lembrete gentil agendado para repetir diariamente');
  }

  /// Estratégia para usuários muito engajados
  Future<void> _scheduleActiveReminder(TimeOfDay time) async {
    debugPrint('🚀 Aplicando estratégia ativa - usuário muito engajado');

    await cancelAllReminders();

    const androidDetails = AndroidNotificationDetails(
      'active_reminder',
      'Lembretes Dinâmicos',
      channelDescription: 'Lembretes dinâmicos para usuários engajados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'active_reminder',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mensagens mais dinâmicas
    final messages = [
      'Hora de registrar seu humor! 🎯',
      'Como está sua energia hoje? ⚡',
      'Vamos refletir sobre este momento! 🤔',
      'Que tal compartilhar como se sente? 🎭',
    ];

    final message = messages[DateTime.now().day % messages.length];

    await _notifications.periodicallyShow(
      2,
      'MoodDot - Check-in diário! 📊',
      message,
      RepeatInterval.daily,
      details,
    );

    debugPrint('🚀 Lembrete dinâmico agendado para repetir diariamente');
  }

  /// Estratégia padrão para usuários moderadamente engajados
  Future<void> _scheduleStandardReminder(TimeOfDay time) async {
    debugPrint('📱 Aplicando estratégia padrão');

    await cancelAllReminders();

    const androidDetails = AndroidNotificationDetails(
      'standard_reminder',
      'Lembretes Diários',
      channelDescription: 'Lembretes diários para registrar humor',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'standard_reminder',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final message = _getTimeBasedMessage(time);

    await _notifications.periodicallyShow(
      0,
      'Como você está se sentindo? 😊',
      message,
      RepeatInterval.daily,
      details,
    );

    debugPrint('📱 Lembrete padrão agendado para repetir diariamente');
  }

  /// Gera mensagem baseada no horário
  String _getTimeBasedMessage(TimeOfDay time) {
    final hour = time.hour;

    if (hour >= 6 && hour < 12) {
      return 'Que tal registrar como você começou o dia?';
    } else if (hour >= 12 && hour < 17) {
      return 'Como está sendo sua tarde? Registre seu humor!';
    } else if (hour >= 17 && hour < 21) {
      return 'Como foi seu dia? Não esqueça de registrar seu humor!';
    } else {
      return 'Antes de dormir, que tal refletir sobre seu dia?';
    }
  }

  /// Aprende com o comportamento do usuário
  Future<void> learnFromUserBehavior({
    required bool respondedToNotification,
    required TimeOfDay responseTime,
  }) async {
    debugPrint('🎓 Aprendendo com comportamento do usuário...');

    final prefs = await SharedPreferences.getInstance();

    if (respondedToNotification) {
      // Usuário respondeu - aumenta engajamento e salva horário preferido
      final currentScore = prefs.getDouble(_userEngagementKey) ?? 0.5;
      final newScore = (currentScore + 0.1).clamp(0.0, 1.0);
      await prefs.setDouble(_userEngagementKey, newScore);

      // Salva horário como preferido (formato HHMM)
      final timeInt = responseTime.hour * 100 + responseTime.minute;
      await prefs.setInt(_preferredTimeKey, timeInt);

      debugPrint('📈 Engajamento aumentado para: $newScore');
      debugPrint(
        '⏰ Horário preferido atualizado: ${responseTime.hour}:${responseTime.minute}',
      );
    }

    // Marca que houve atividade hoje
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await prefs.setString(_lastNotificationKey, todayString);
  }

  /// Cancela todos os lembretes (real)
  Future<void> cancelAllReminders() async {
    debugPrint('🚫 Cancelando todas as notificações...');
    await _notifications.cancelAll();
    debugPrint('✅ Todas as notificações canceladas');
  }

  /// Obtém o status atual dos lembretes
  Future<Map<String, dynamic>> getReminderStatus() async {
    final enabled = await areNotificationsEnabled();

    return {'enabled': enabled};
  }

  /// Testa uma notificação imediatamente (real)
  Future<void> testNotification() async {
    debugPrint('🧪 Enviando notificação de teste real...');

    const androidDetails = AndroidNotificationDetails(
      'test',
      'Teste',
      channelDescription: 'Notificação de teste',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(threadIdentifier: 'test');

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Teste de Notificação 🧪',
      'Esta é uma notificação de teste para verificar se está funcionando!',
      details,
    );

    debugPrint('✅ Notificação de teste enviada com sucesso!');
  }

  /// Chamado quando o usuário registra um humor - usado para aprendizado
  Future<void> onMoodRegistered() async {
    debugPrint('🎭 Humor registrado - atualizando sistema inteligente');

    final now = TimeOfDay.now();
    await learnFromUserBehavior(
      respondedToNotification: true,
      responseTime: now,
    );

    // Reagenda próximas notificações com base no novo aprendizado
    final enabled = await areNotificationsEnabled();
    if (enabled) {
      await _scheduleReminder();
    }
  }

  /// Reseta o sistema de aprendizado (para testes ou novo usuário)
  Future<void> resetLearningSystem() async {
    debugPrint('🔄 Resetando sistema de aprendizado');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEngagementKey);
    await prefs.remove(_preferredTimeKey);
    await prefs.remove(_lastNotificationKey);

    debugPrint('✅ Sistema resetado - voltando aos padrões');
  }
}
