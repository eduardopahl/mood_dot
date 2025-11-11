#!/bin/bash

# Script para corrigir os erros de AppLocalizations nullable em todos os arquivos

echo "Aplicando correções de AppLocalizations nullable..."

# Lista de arquivos para corrigir (excluindo a extensão que já está correta)
files=(
    "lib/presentation/pages/add_mood_page.dart"
    "lib/presentation/pages/settings_page.dart" 
    "lib/presentation/widgets/daily_mood_card.dart"
    "lib/presentation/widgets/mood_selector.dart"
    "lib/presentation/widgets/mood_entry_card.dart"
    "lib/presentation/pages/main_navigation_page.dart"
    "lib/presentation/pages/calendar_page.dart"
    "lib/presentation/pages/statistics_page.dart"
)

# Para cada arquivo
for file in "${files[@]}"; do
    echo "Processando: $file"
    
    # 1. Adicionar import da extensão (se não existir)
    if ! grep -q "import '../../core/extensions/app_localizations_extension.dart';" "$file"; then
        # Adicionar o import após o import do app_localizations.dart
        sed -i '' "/import '..\/..\/generated\/l10n\/app_localizations.dart';/a\\
import '../../core/extensions/app_localizations_extension.dart';
" "$file"
    fi
    
    # 2. Substituir AppLocalizations.of(context) por context.l10n
    sed -i '' 's/AppLocalizations\.of(context)/context.l10n/g' "$file"
    
    # 3. Substituir declarações final l10n = AppLocalizations.of(context);
    sed -i '' 's/final l10n = AppLocalizations\.of(context);/final l10n = context.l10n;/g' "$file"
    
    echo "  ✓ Concluído: $file"
done

echo "Todas as correções aplicadas!"
echo "Executando flutter analyze para verificar..."

flutter analyze