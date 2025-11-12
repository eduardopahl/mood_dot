// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get homeTitle => 'Início';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get calendar => 'Calendário';

  @override
  String get settings => 'Configurações';

  @override
  String get statisticsTitle => 'Estatísticas';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get moodVeryHappy => 'Muito Bem';

  @override
  String get moodHappy => 'Bem';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodSad => 'Ruim';

  @override
  String get moodVerySad => 'Muito Ruim';

  @override
  String get addMoodTitle => 'Adicionar Humor';

  @override
  String get editMoodTitle => 'Editar Humor';

  @override
  String get moodSaved => 'Humor registrado com sucesso!';

  @override
  String get moodUpdated => 'Humor atualizado com sucesso!';

  @override
  String get selectMood => 'Como você está se sentindo?';

  @override
  String get addNote => 'Adicionar observação (opcional)';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String lastDays(int days) {
    return 'Últimos $days dias';
  }

  @override
  String get allTime => 'Todo período';

  @override
  String get averageMood => 'Humor Médio';

  @override
  String get totalEntries => 'Total de Registros';

  @override
  String get bestDay => 'Melhor Dia';

  @override
  String get worstDay => 'Pior Dia';

  @override
  String get moodDistribution => 'Distribuição de Humores';

  @override
  String get weeklyPattern => 'Padrão Semanal';

  @override
  String get noDataAvailable => 'Nenhum dado disponível';

  @override
  String get appearance => 'Aparência';

  @override
  String get notifications => 'Notificações';

  @override
  String get about => 'Sobre';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get enabled => 'Ativado';

  @override
  String get disabled => 'Desativado';

  @override
  String get dailyReminders => 'Lembretes diários';

  @override
  String get sendTestNotification => 'Enviar notificação de teste';

  @override
  String get resetAI => 'Resetar IA';

  @override
  String get resetAIDescription =>
      'Remove padrões aprendidos de horários e preferências de notificação';

  @override
  String get resetIntelligentSystem => 'Resetar Sistema Inteligente?';

  @override
  String get resetConfirmation =>
      'Isso irá limpar todos os dados aprendidos:\n\n• Horários preferidos para notificações\n• Padrões de humor identificados\n• Configurações de personalização da IA\n\nEsta ação não pode ser desfeita.';

  @override
  String get reset => 'Resetar';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get language => 'Idioma';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'Inglês';

  @override
  String get reminderNotifications => 'Lembretes de Notificação';

  @override
  String get testNotification => 'Testar Notificação';

  @override
  String get resetLearning => 'Resetar Aprendizado';

  @override
  String get version => 'Versão';

  @override
  String get premiumUpgrade => 'Upgrade Premium';

  @override
  String get removeAds => 'Remover Anúncios - \$0,99';

  @override
  String get premiumFeatures => 'Recursos Premium';

  @override
  String get noAds => 'Sem anúncios';

  @override
  String get unlimitedEntries => 'Registros ilimitados';

  @override
  String get advancedStatistics => 'Estatísticas avançadas';

  @override
  String get dataExport => 'Exportar seus dados';

  @override
  String get buyPremium => 'Comprar Premium';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get alreadyPremium => 'Você já tem Premium!';

  @override
  String get notificationTitle => 'Como você está se sentindo?';

  @override
  String get notificationBody => 'Reserve um momento para registrar seu humor';

  @override
  String get testNotificationTitle => 'Notificação de Teste';

  @override
  String get testNotificationBody => 'Esta é uma notificação de teste!';

  @override
  String get testNotificationSent =>
      'Notificação de teste enviada com sucesso!';

  @override
  String get permissionDenied => 'Permissão de notificação negada';

  @override
  String get permissionGranted => 'Permissão de notificação concedida';

  @override
  String get gentleNotificationMessage1 =>
      'Como você está se sentindo hoje? 😊';

  @override
  String get gentleNotificationMessage2 => 'Que tal compartilhar seu humor? 💭';

  @override
  String get gentleNotificationMessage3 =>
      'Um minutinho para refletir sobre seu dia? 🌟';

  @override
  String get activeNotificationTitle => 'MoodDot - Check-in diário! 📊';

  @override
  String get activeNotificationMessage1 => 'Hora de registrar seu humor! 🎯';

  @override
  String get activeNotificationMessage2 => 'Como está sua energia hoje? ⚡';

  @override
  String get activeNotificationMessage3 =>
      'Vamos refletir sobre este momento! 🤔';

  @override
  String get activeNotificationMessage4 =>
      'Que tal compartilhar como se sente? 🎭';

  @override
  String get standardNotificationTitle => 'Como você está se sentindo? 😊';

  @override
  String get morningNotificationMessage =>
      'Que tal registrar como você começou o dia?';

  @override
  String get afternoonNotificationMessage =>
      'Como está sendo sua tarde? Registre seu humor!';

  @override
  String get eveningNotificationMessage =>
      'Como foi seu dia? Não esqueça de registrar seu humor!';

  @override
  String get nightNotificationMessage =>
      'Antes de dormir, que tal refletir sobre seu dia?';

  @override
  String get gentleReminderTitle => 'MoodDot 💙';

  @override
  String get testNotificationFinalTitle => 'Teste de Notificação 🧪';

  @override
  String get testNotificationFinalBody =>
      'Esta é uma notificação de teste para verificar se está funcionando!';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get confirm => 'Confirmar';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get loading => 'Carregando...';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get close => 'Fechar';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana passada';

  @override
  String get thisMonth => 'Este mês';

  @override
  String get lastMonth => 'Mês passado';

  @override
  String get hello => 'Olá! 👋';

  @override
  String get howAreYouToday => 'Como você está hoje?';

  @override
  String get noRecordsYet => 'Nenhum registro ainda';

  @override
  String get tapToAddFirstMood =>
      'Toque no + para registrar seu primeiro humor';

  @override
  String get showOnlyRecent => 'Mostrar apenas recentes';

  @override
  String get viewFullHistory => 'Ver histórico completo';

  @override
  String get showingFullHistory => 'Mostrando histórico completo';

  @override
  String get showingLast30Days => 'Mostrando últimos 30 dias';

  @override
  String get errorOccurred => 'Ops, algo deu errado';

  @override
  String get howAreYouFeeling => 'Como você está se sentindo?';

  @override
  String get addNoteOptional => 'Adicione uma nota (opcional)';

  @override
  String get howWasYourDay => 'Como foi o seu dia? O que aconteceu?';

  @override
  String get editingRecord => 'Editando registro';

  @override
  String createdAt(String date) {
    return 'Criado em $date';
  }

  @override
  String get updateMood => 'Atualizar Humor';

  @override
  String get saveMood => 'Salvar Humor';

  @override
  String get update => 'Atualizar';

  @override
  String get date => 'Data';

  @override
  String get time => 'Hora';

  @override
  String errorLoadingData(String error) {
    return 'Erro ao carregar dados: $error';
  }

  @override
  String get weekdaysShort => 'Dom,Seg,Ter,Qua,Qui,Sex,Sáb';

  @override
  String get last7Days => 'Últimos 7 dias';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get last90Days => 'Últimos 90 dias';

  @override
  String get noDataToShow => 'Sem dados para exibir';

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get last7DaysLabel => 'Últimos 7 dias';

  @override
  String get last30DaysLabel => 'Últimos 30 dias';

  @override
  String get last90DaysLabel => 'Últimos 90 dias';

  @override
  String get allTimeLabel => 'Todo período';

  @override
  String get averageMoodLabel => 'Humor Médio';

  @override
  String get totalEntriesLabel => 'Total Registros';

  @override
  String get moodDistributionLabel => 'Distribuição de Humores';

  @override
  String get weeklyPatternLabel => 'Semana atual';

  @override
  String get currentWeek => 'Semana atual';

  @override
  String get timeline30Days => 'Últimos 30 dias';

  @override
  String get veryBad => 'Muito Triste';

  @override
  String get bad => 'Triste';

  @override
  String get neutral => 'Neutro';

  @override
  String get good => 'Feliz';

  @override
  String get veryGood => 'Muito Feliz';

  @override
  String get noDataToDisplay => 'Sem dados para exibir';

  @override
  String get loadingData => 'Carregando dados...';

  @override
  String get moodLevelUnknown => 'Desconhecido';

  @override
  String get moodDotPremium => 'MoodDot Premium';

  @override
  String get supportDevelopment => 'Apoie o desenvolvimento';

  @override
  String get buyPremiumPrice => 'Comprar Premium - \$0.99';

  @override
  String get premiumActivated => 'Premium Ativado!';

  @override
  String get thanksForSupport => 'Obrigado por apoiar o MoodDot!';

  @override
  String get premiumActivatedMessage =>
      'Todos os anúncios foram removidos e você agora tem acesso premium completo.';

  @override
  String get excellent => 'Excelente!';

  @override
  String get purchaseError => 'Erro na compra. Tente novamente.';

  @override
  String get tryAgain => 'Tente novamente';

  @override
  String unexpectedError(Object error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get restoringPurchases => 'Restaurando compras...';

  @override
  String get purchasesRestored => 'Compras Restauradas!';

  @override
  String get purchasesRestoredMessage =>
      'Suas compras foram restauradas com sucesso!\n\nO acesso premium foi reativado.';

  @override
  String get noPurchasesFound => 'Nenhuma compra anterior encontrada.';

  @override
  String restoreError(Object error) {
    return 'Erro ao restaurar: $error';
  }

  @override
  String get youHavePremiumAccess => 'Você tem acesso premium ativo!';

  @override
  String get resetIntelligentSystemMessage =>
      'Sistema inteligente resetado com sucesso!';

  @override
  String get aiResetSuccess => 'Sistema inteligente resetado com sucesso!';

  @override
  String get moodUpdatedSuccess => 'Humor atualizado com sucesso!';

  @override
  String get moodSavedSuccess => 'Humor registrado com sucesso!';

  @override
  String errorSaving(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get editAction => 'Editar';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get recordSingle => 'registro';

  @override
  String get recordPlural => 'registros';

  @override
  String get tryAgainLater => 'Tente novamente em alguns instantes';

  @override
  String get deleteRecord => 'Excluir registro';

  @override
  String get confirmDeleteRecord =>
      'Tem certeza que deseja excluir este registro de humor?';

  @override
  String get recordDeletedSuccess => 'Registro excluído com sucesso';

  @override
  String get trend => 'Tendência';

  @override
  String get overallAverage => 'Média Geral';

  @override
  String get hardestDay => 'Dia Mais Difícil';

  @override
  String get sunday => 'Domingo';

  @override
  String get tuesday => 'Terça';

  @override
  String get records => 'registros';

  @override
  String get last30DaysData => 'Últimos 30 dias';

  @override
  String get noDataLast30Days => 'Sem dados dos últimos 30 dias';

  @override
  String get monday => 'Segunda';

  @override
  String get wednesday => 'Quarta';

  @override
  String get thursday => 'Quinta';

  @override
  String get friday => 'Sexta';

  @override
  String get saturday => 'Sábado';

  @override
  String get improving => 'Melhorando';

  @override
  String get declining => 'Declinando';

  @override
  String get stable => 'Estável';

  @override
  String get consistentMood =>
      'Humor consistente nos últimos 30 dias. Variação: ';
}
