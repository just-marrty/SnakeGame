# CloudKit Setup Instructions

## 1. Apple Developer Account Setup

1. Přihlaste se do [Apple Developer Portal](https://developer.apple.com)
2. Přejděte do "Certificates, Identifiers & Profiles"
3. Vyberte "Identifiers" a najděte váš App ID
4. Ujistěte se, že máte povolené:
   - CloudKit
   - iCloud

## 2. Xcode Project Setup

1. Otevřete projekt v Xcode
2. Vyberte váš target "SnakeGame"
3. Přejděte na záložku "Signing & Capabilities"
4. Klikněte na "+ Capability" a přidejte:
   - CloudKit
   - iCloud

## 3. CloudKit Dashboard Setup

1. Přejděte na [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
2. Vyberte váš App ID
3. Vytvořte nový Record Type s názvem "HighScore" s následujícími poli:
   - `score` (Int64, Queryable)
   - `playerName` (String, Queryable)
   - `date` (Date/Time, Queryable)

## 4. Update Entitlements

V souboru `SnakeGame.entitlements` upravte container identifier na váš skutečný:

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.yourcompany.SnakeGame</string>
</array>
```

## 5. Testování

1. Spusťte aplikaci na fyzickém zařízení (CloudKit nefunguje v simulátoru)
2. Přihlaste se do iCloud na zařízení
3. Zahrajte si hru a dosáhněte skóre
4. Zkontrolujte, že se skóre ukládá do CloudKit

## 6. Troubleshooting

- Ujistěte se, že jste přihlášeni do iCloud na zařízení
- Zkontrolujte, že máte správně nastavené entitlements
- Ověřte, že CloudKit Dashboard má správně nakonfigurovaný Record Type
- Zkontrolujte console logy pro případné chyby

## 7. Production Deployment

Před nasazením do App Store:
1. Otestujte na více zařízeních
2. Zkontrolujte CloudKit Dashboard pro správné nastavení
3. Ověřte, že všechny CloudKit operace fungují správně 