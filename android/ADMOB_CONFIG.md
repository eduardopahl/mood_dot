# Configuração AdMob - Android

Para configurar o App ID do AdMob no Android:

1. Crie o arquivo:
   ```
   android/app/src/main/res/values/admob_config.xml
   ```

2. Adicione o conteúdo:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <string name="admob_app_id">SEU_APP_ID_AQUI</string>
   </resources>
   ```

3. Substitua `SEU_APP_ID_AQUI` pelo seu App ID real do AdMob.

**Exemplo:**
```xml
<string name="admob_app_id">ca-app-pub-1234567890123456~1234567890</string>
```