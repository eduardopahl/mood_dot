import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mooddot/presentation/widgets/mood_selector.dart';
import 'package:mooddot/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('MoodSelector taps update selected mood via callback', (
    WidgetTester tester,
  ) async {
    int selected = 1;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MoodSelector(
              selectedMoodLevel: selected,
              onMoodSelected: (v) {
                selected = v;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Precisa ter 5 GestureDetectors (um para cada humor)
    final gestures = find.byType(GestureDetector);
    expect(gestures, findsNWidgets(5));

    // Toca o último humor (índice 4 -> nível de humor 5)
    await tester.tap(gestures.at(4));
    await tester.pumpAndSettle();

    expect(selected, 5);

    // Slider deve estar presente
    expect(find.byType(Slider), findsOneWidget);
  });
}
