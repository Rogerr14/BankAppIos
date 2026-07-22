# BankApp iOS

Aplicación nativa de simulación bancaria desarrollada con SwiftUI, Swift Concurrency y MVVM. Consume exclusivamente los endpoints disponibles en `BankAppBack` y usa una identidad visual magenta inspirada en las referencias entregadas, sin copiar marcas ni logotipos.

## Requisitos

- macOS con Xcode 16 o posterior.
- iOS 17 o posterior.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen).
- La API `BankAppBack` en ejecución y con las migraciones aplicadas.

## Generar y abrir el proyecto

```bash
brew install xcodegen
cd BankAppiOS
xcodegen generate
open BankApp.xcodeproj
```

Selecciona el scheme `BankApp Dev` o `BankApp Prod`. Configura el equipo de firma desde Xcode; el proyecto no incluye un `DEVELOPMENT_TEAM` para no sobrescribir la cuenta del desarrollador.

## Ambientes

| Ambiente | Archivo | Bundle ID | URL inicial |
| --- | --- | --- | --- |
| Dev | `Config/Dev.xcconfig` | `com.rruiz.bankapp.dev` | `http://localhost:5169/` |
| Prod | `Config/Prod.xcconfig` | `com.rruiz.bankapp` | `https://api.example.com/` |

La excepción de tráfico local se aplica únicamente a las configuraciones Dev. Producción debe usar HTTPS. Para consumir el backend desde un iPhone físico, reemplaza `localhost` por la IP local del computador y revisa el firewall.

## Arquitectura

```text
BankApp/
├── App/                      # Composición y navegación raíz
├── Core/
│   ├── Banking/              # Enums tolerantes a valores desconocidos
│   ├── Config/               # Ambiente activo
│   ├── DesignSystem/         # Colores, campos, botones y fecha
│   ├── Extensions/           # Fechas y moneda
│   ├── Networking/           # APIClient, endpoints e interceptores
│   └── Security/             # Sesión, Keychain y biometría
├── Features/
│   ├── Splash/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Accounts/
│   └── Transactions/
└── Models/                   # DTO alineados con el backend
```

Las vistas no acceden directamente a `URLSession`, Keychain ni `LAContext`. Los ViewModels coordinan servicios y estado de presentación.

## Networking y sesión

- `AuthRequestInterceptor` adjunta `Authorization: Bearer <token>` a endpoints protegidos.
- `SessionResponseInterceptor` intercepta cualquier `401`, elimina solamente la sesión JWT y vuelve al Login.
- `APIClient` decodifica `ServiceResult<T>` y centraliza errores HTTP, transporte y decodificación.
- No existe refresh token ni renovación silenciosa.
- El JWT, la expiración, el nombre y el usuario se guardan como una sesión en Keychain con `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- Splash valida `expiresAtUtc`; un `401` sigue siendo la autoridad final porque el backend también controla inactividad y revocación.

## Login biométrico de simulación

Después de un login normal, el usuario puede habilitar Face ID o Touch ID. La aplicación solicita autenticación y guarda usuario/contraseña en un item de Keychain protegido con `SecAccessControl`, `.biometryCurrentSet` y `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. En el siguiente acceso, la biometría desbloquea esas credenciales y se ejecuta un nuevo `POST /api/auth/login`.

Esta es una simplificación válida únicamente para la simulación. Una banca real debería utilizar registro de dispositivo, passkeys o un desafío criptográfico del backend. Las contraseñas y los tokens no se guardan en `UserDefaults`, archivos ni logs. `UserDefaults` contiene solamente un indicador booleano no sensible para saber si la opción biométrica estaba habilitada.

## Funcionalidad

- Splash y bienvenida con primer nombre.
- Registro con validaciones alineadas al backend.
- Login normal, visibilidad de contraseña y recuperación visual sin endpoint.
- Activación, uso y desactivación de Face ID/Touch ID.
- Dashboard con saldo total, cuentas y últimos movimientos.
- Listado y detalle de cuentas.
- Historial con búsqueda de 500 ms, filtros, fechas, agrupación y paginación incremental.
- Prevención de páginas duplicadas.
- Exportación XLSX con rango máximo de 366 días, filtros y `fileExporter`.
- Estados de carga, vacío y error.
- Keychain y cierre global ante `401`.

## Endpoints consumidos

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/dashboard
GET  /api/accounts
GET  /api/accounts/{accountId}
GET  /api/accounts/{accountId}/transactions
GET  /api/accounts/{accountId}/transactions/export
```

La aplicación nunca envía `userAccountId` para consultar información bancaria y no calcula ni modifica saldos localmente.

## Pruebas incluidas

- Mensajes de errores globales.
- Validaciones principales de registro.
- Fechas y construcción de filtros.
- Preservación de enums bancarios desconocidos.

## Verificación antes de integrar

Este ZIP fue generado en un entorno Linux sin Xcode, por lo que se validaron estructura, YAML, archivos y consistencia estática, pero el build final debe ejecutarse en macOS:

```bash
xcodegen generate
xcodebuild -project BankApp.xcodeproj -scheme "BankApp Dev" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -project BankApp.xcodeproj -scheme "BankApp Dev" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

Después del primer build, configura firma, revisa las advertencias específicas de tu versión de Xcode y prueba Face ID desde `Features > Face ID > Enrolled` en el simulador.
"# BankAppIos" 
