# Firebase Setup (Plan Gratuito Spark)

Fecha: 5 de marzo de 2026

## 1) Crear cuenta/proyecto en Firebase
1. Entra en `https://console.firebase.google.com/`.
2. Inicia sesión con tu cuenta de Google.
3. Pulsa **Crear un proyecto**.
4. Pon nombre al proyecto (por ejemplo `taberna-del-buho-clase`).
5. Desactiva Google Analytics para este proyecto de clase.
6. Confirma que estás en plan **Spark (gratuito)** y no añadas facturación.

## 2) Registrar la app Android
1. Dentro del proyecto, pulsa el icono de **Android**.
2. Usa este `applicationId`:
   - `com.example.appantibloqueo`
3. Descarga `google-services.json`.
4. Copia el archivo en:
   - `android/app/google-services.json`

## 3) Activar productos Firebase
1. **Authentication**:
   - Ve a Authentication > Sign-in method.
   - Activa `Email/Password`.
2. **Cloud Firestore**:
   - Crea la base en modo producción.
   - Región recomendada UE: Bélgica (`europe-west`).
3. **Cloud Storage**:
   - Habilita Storage.

## 4) Configurar usuario admin
1. Ve a Firestore y crea colección:
   - `admin_emails`
2. Crea documento con ID = correo admin en minúsculas.
   - Ejemplo ID: `tu_correo@gmail.com`
3. Campo del documento:
   - `enabled: true`

## 5) Reglas de seguridad
1. Publica reglas de Firestore desde:
   - `firestore.rules`
2. Publica reglas de Storage desde:
   - `storage.rules`

## 6) Configuración FlutterFire (Android)
Ejecuta en terminal (raíz del proyecto):

```bash
flutterfire configure --platforms=android --android-package-name com.example.appantibloqueo
flutter pub get
```

## 7) Ejecutar la app
```bash
flutter run
```

## 8) Flujo esperado
1. Registro con correo/contraseña.
2. Llegará correo de verificación.
3. Hasta verificar correo no se entra al Home.
4. Si el usuario está `isActive=false` en Firestore, queda bloqueado.
5. Si el correo está en `admin_emails`, se habilita rol admin.

## 9) Carga inicial de datos
- Al entrar un admin, la app intenta sembrar automáticamente:
  - `assets/musica.json` -> colección `songs`
  - `assets/noticias.json` -> colección `news`
- También puedes importar manualmente:
  - Desde pantalla Playlist (admin): importación de canciones.
  - Desde pantalla Noticias (admin): importación de noticias.

## 10) Limpieza automática de cuentas no verificadas (Auth)
Se ha añadido una Cloud Function programada en `functions/index.js` que elimina
usuarios de Authentication no verificados tras un tiempo mínimo.

1. Instala dependencias:
   - `cd functions && npm install`
2. (Opcional) Cambia horas mínimas antes de borrar:
   - variable entorno `UNVERIFIED_ACCOUNT_MAX_AGE_HOURS` (por defecto `24`)
3. Despliega:
   - `firebase deploy --only functions`

Notas:
- La función se ejecuta cada 24 horas en zona `Europe/Madrid`.
- Solo afecta a usuarios de proveedor `email/password` con `emailVerified=false`.
- Para funciones programadas puede requerirse plan con facturación activa.
