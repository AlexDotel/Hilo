# Hilo (`nuviapps.co.hilo`)

Rastreador de hábitos *local-first* desarrollado en **Flutter** con **mapa de calor tipo GitHub**, **rachas flexibles anti-burnout** y **widgets interactivos para la pantalla de inicio de Android** (`home_widget`).

## Arquitectura e Ingeniería

- **Clean Architecture (Feature-First + Hexagonal Ports & Adapters):**
  - `lib/core/`: `Clock` y `LocalDate` (inmune a cambios de zona horaria/DST), `Result<T, E>` algebraico, temas *Papel Cálido* (Light) y *Pizarra Nocturna* (Dark), `HiloDatabase` (Drift + SQLCipher) y servicios de seguridad.
  - `lib/features/habits/`: Entidades de dominio, programación flexible (`DailySchedule`, `SpecificDaysSchedule`, `TimesPerWeekSchedule`), repositorio Drift y pantallas de gestión/edición.
  - `lib/features/tracking/`: `ScheduleStrategy` (Strategy Pattern), `StreakEngine` (escudos de gracia automáticos cada 7 días, días de descanso y consistencia de 30 días), `HeatmapBuilder`, `HeatmapGrid` (`CustomPainter` de 5 niveles) y pantallas *Hoy* y *Mapa de Calor*.
  - `lib/features/widget_sync/`: Proyección mínima `WidgetSnapshot` (nunca expone notas privadas), `WidgetActionValidator` (whitelist estricta de URIs y UUIDs) y puente `home_widget` con callback en segundo plano (`@pragma('vm:entry-point')`).
  - `lib/features/backup/`: Exportación e importación de respaldos locales `.hilo` cifrados con **AES-256-GCM + PBKDF2-HMAC-SHA256**.

## Seguridad y Privacidad

- **Base de datos cifrada en reposo:** SQLite con **SQLCipher** (hook nativo en `sqlite3` v3) y llave de 256 bits generada con `Random.secure()` almacenada en **Android Keystore** (`flutter_secure_storage`).
- **Cero permiso `INTERNET` en Android:** Toda la información permanece 100% en tu dispositivo.
- **Protección de pantalla y biometría opcional:** `local_auth` + `WindowManager.LayoutParams.FLAG_SECURE` vía MethodChannel en `MainActivity.kt`.
- **Hardening Android:** `android:allowBackup="false"`, `minSdk = 23`, R8/ProGuard habilitado en release.

## Widgets de Escritorio Android (`home_widget`)

- **Hilo · Mapa de Calor (4×2):** `HiloWidgetProvider.kt` + renderizado nativo `Canvas` (`HeatmapBitmapRenderer.kt`) de 16 semanas y check-in directo en segundo plano.
- **Hilo · Hábito Rápido (2×2):** `HiloSingleHabitWidgetProvider.kt` con cuadrícula de 5 semanas, meta semanal y botón `+` interactivo.

## Comandos de Desarrollo

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```
