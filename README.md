

# TRABAJO DE FIN DE GRADO
## La Taberna del Búho
**Aplicación móvil de entretenimiento y comunidad para aficionados a los juegos de rol**


[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)


**Autores:** Maria, Alberto, Tony, Manuel  
**Titulación:** Desarrollo de Aplicaciones Multiplataforma  
**Curso académico:** 2025 – 2026  
**Tecnologías:** Flutter, Dart, Firebase, Cloud Functions, Hive

---

## Resumen
La Taberna del Búho es una aplicación móvil multiplataforma desarrollada con Flutter y respaldada por Firebase como infraestructura de backend. Su objetivo es centralizar herramientas dispersas utilizadas por jugadores de rol de mesa, integrando gestión de personajes, consulta de bestiario y grimorio, música de ambiente, noticias del sector y notas de campaña en una única interfaz.

El sistema implementa un modelo de autenticación restrictivo con verificación de correo y activación manual por administrador, gestionado mediante reglas de seguridad en servidor (Firestore). La arquitectura cliente sigue un patrón Feature-First con separación estricta de responsabilidades, utilizando Provider para la gestión de estado. Para garantizar latencia cero y funcionamiento offline en catálogos pesados, el Bestiario y el Grimorio se empaquetan como constantes inmutables de Dart, mientras que Hive se utiliza para caché de preferencias y datos dinámicos. El backend se complementa con Cloud Functions para tareas de mantenimiento automatizadas y borrado en cascada.

**Palabras clave:** Flutter, Firebase, Firestore, Dart, juegos de rol, arquitectura Feature-First, seguridad en servidor, persistencia local.

---

## Índice de contenidos
1. Introducción
2. Objetivos
3. Estado del arte
4. Tecnologías utilizadas
5. Arquitectura del sistema
6. Diseño de la aplicación
7. Implementación
8. Base de datos y Firebase
9. Seguridad
10. Rendimiento y optimización
11. Testing
12. Problemas encontrados
13. Resultados
14. Líneas futuras
15. Conclusiones
16. Bibliografía
17. Anexos

---

## 1. Introducción

### 1.1. Contexto y motivación
Los juegos de rol de mesa han experimentado un crecimiento notable en la última década. Esta comunidad requiere consultar reglas, estadísticas de monstruos y hechizos constantemente durante las partidas. Sin embargo, las soluciones actuales están fragmentadas: los jugadores utilizan aplicaciones distintas para la ficha de personaje, la música de ambiente y la consulta de reglas. 

El objetivo de La Taberna del Búho es unificar estas herramientas en una aplicación móvil nativa, aprovechando el stack Flutter y Firebase para garantizar sincronización en la nube y un funcionamiento offline robusto para los catálogos de datos estáticos.

### 1.2. Problemática detectada
Desde el punto de vista del usuario, el problema es la fricción de cambiar entre múltiples aplicaciones durante una sesión de juego. Desde el punto de vista técnico, el proyecto aborda el reto de manejar grandes volúmenes de datos estáticos pero complejos (como las tablas de monstruos y hechizos) sin depender de una conexión activa ni disparar cuotas de lectura en Firestore. Además, se ha buscado implementar un control de acceso basado en roles real, evitando la simplificación académica donde cualquier usuario registrado tiene acceso total.

### 1.3. Alcance del proyecto
El proyecto abarca el desarrollo completo de una aplicación Flutter multiplataforma con las siguientes funcionalidades: autenticación con verificación de email y roles, gestión de fichas de personajes, consulta y filtrado offline de Bestiario y Grimorio, reproductor de música, lector de noticias, notas privadas, notificaciones push y panel de administración. Quedan fuera del alcance el soporte completo para Web/Desktop y el chat en tiempo real entre usuarios.

---

## 2. Objetivos

### 2.1. Objetivos generales
Diseñar e implementar una aplicación móvil multiplataforma que centralice utilidades para jugadores de rol, manteniendo una arquitectura segura, escalable y con soporte offline para catálogos de datos pesados.

### 2.2. Objetivos específicos
1. Implementar autenticación con Firebase Auth, verificación de email y control de acceso por rol (usuario activo/administrador).
2. Desarrollar el módulo de gestión de personajes con persistencia en Firestore.
3. Implementar el módulo de Bestiario y Grimorio, permitiendo consultas complejas y filtrado en cliente con latencia cero.
4. Integrar un reproductor de música de ambiente con playlists personales.
5. Crear módulos de noticias y notas privadas sincronizadas.
6. Desarrollar un panel de administración para gestión de usuarios y contenido.
7. Garantizar la seguridad mediante reglas de Firestore validadas en servidor.
8. Implementar persistencia local con Hive para preferencias y caché de datos dinámicos.

### 2.3. Requisitos funcionales
| ID | Descripción | Módulo |
| :--- | :--- | :--- |
| RF-01 | Registro de usuario con email y contraseña | Autenticación |
| RF-02 | Verificación de email obligatoria antes de acceso | Autenticación |
| RF-03 | Login y logout de usuario | Autenticación |
| RF-04 | Creación, edición y eliminación de personajes | Personajes |
| RF-14 | Consulta de monstruos con filtrado por tipo, nivel de desafío y entorno | Bestiario |
| RF-15 | Consulta de hechizos con filtrado por clase, nivel, escuela y componentes | Grimorio |
| RF-06 | Reproducción de canciones de playlist personal | Música |
| RF-09 | Creación, edición y borrado de notas privadas | Notas |
| RF-11 | Panel admin: activar/desactivar usuarios | Admin |

---

## 3. Estado del arte
Para un equipo de cuatro personas, Flutter permite compartir el código base entre Android e iOS, compilando a nativo mediante el motor Impeller/Skia. La alternativa de usar React Native implicaría lidiar con el puente de JavaScript, lo que penaliza el rendimiento en animaciones complejas y listas largas, críticas para el Bestiario. 

Respecto al backend, construir un servidor propio con Node.js y PostgreSQL habría consumido tiempo en configurar infraestructura, CORS, SSL y despliegues. Firebase permite centrar el esfuerzo en la lógica de negocio y las reglas de seguridad, asumiendo el vendor lock-in como un trade-off aceptable para el alcance de un trabajo de fin de grado.

---

## 4. Tecnologías utilizadas

### 4.1. Flutter y Dart
El proyecto utiliza Dart con null-safety estricto (SDK >=3.3.0). Para la gestión de estado se optó por Provider (v6.1.2). Provider, basado en InheritedWidget, permite inyectar dependencias y escuchar cambios de estado de forma granular, reconstruyendo solo los widgets necesarios sin la verbosidad de patrones como BLoC.

### 4.2. Firebase
- **Authentication:** Ciclo de vida de sesiones y tokens JWT.
- **Cloud Firestore:** Base de datos NoSQL para datos relacionales y tiempo real.
- **Cloud Storage:** Almacenamiento de imágenes de perfil.
- **Cloud Messaging (FCM):** Notificaciones push segmentadas.
- **Cloud Functions:** Lógica de servidor para limpieza de cuentas y borrado en cascada.

### 4.3. Paquetes y dependencias clave
- **hive + hive_flutter:** Persistencia local offline.
- **just_audio:** Reproducción de audio en streaming y local.
- **xml:** Parseado de feeds RSS para noticias.
- **flutter_local_notifications:** Notificaciones locales con soporte de timezone.

---

## 5. Arquitectura del sistema

### 5.1. Visión general
Se ha implementado una arquitectura Feature-First (orientada a funcionalidades) dentro de `lib/features/`, donde cada módulo contiene sus propias subcapas de data, domain y presentation. Esto encapsula completamente la lógica de negocio y facilita el escalado del código, alejándose de las estructuras monolíticas por capas.

### 5.2. Estructura de carpetas
```text
lib/
├── app/                       # bootstrap.dart, app.dart y seed services
├── core/                      # Proveedores globales (AudioProvider, SnowProvider)
├── features/
│   ├── auth/                  # Autenticación y control de roles
│   ├── dnd/                   # Módulo principal de D&D
│   │   ├── data/              # Repositorios (character_repository.dart)
│   │   ├── domain/            # Modelos y reglas (rules/constants.dart)
│   │   └── presentation/      # UI (bestiary_page.dart, spells_page.dart, combat_page.dart)
│   ├── news/                  # Lector de noticias y RSS
│   ├── notes/                 # Notas privadas
│   ├── playlist/              # Reproductor de música
│   └── profile/               # Gestión de perfil
└── legacy/                    # Código antiguo en proceso de migración
```

### 5.3. Flujo de datos
Cuando el usuario realiza una acción, el widget llama al método del Provider, que invoca el servicio de Firestore. El servicio escribe en la subcolección correspondiente y Firestore notifica en tiempo real mediante un Stream. El Provider recibe el evento, actualiza su estado con notifyListeners() y Flutter reconstruye únicamente los widgets afectados.

---

## 6. Diseño de la aplicación
El diseño sigue una estética oscura utilizando ThemeData personalizado con paletas ámbar y gris antracita. Para el Bestiario y el Grimorio, dado que son listas largas, se ha optado por usar CustomScrollView con SliverList y SliverAppBar para garantizar que el scroll sea fluido y la memoria se libere correctamente al reciclar los widgets fuera de pantalla.

---

## 7. Implementación

### 7.1. Módulo de Autenticación y Roles
El flujo de login no termina al crear la cuenta en Firebase Auth. Se implementa un StreamBuilder que escucha authStateChanges(). Si el usuario existe pero emailVerified es falso, se le redirige a una pantalla de espera que hace polling (user.reload()) cada pocos segundos. Si el email está verificado, se consulta el documento en Firestore para comprobar el campo isActive. Solo si es true, se permite el acceso a la HomeScreen.

### 7.2. Módulo D&D: Personajes, Bestiario y Grimorio
El núcleo de la aplicación es el módulo features/dnd. Para garantizar latencia cero y un funcionamiento offline total, el catálogo de reglas, monstruos y hechizos no se descarga de Firestore en tiempo real, sino que viaja empaquetado en la propia aplicación.

**Bestiario y Grimorio (Hardcoded Constants):**
Todas las reglas de la 5ª edición (atributos, point buy, razas, subrazas, bonificaciones y listas de hechizos por nivel) están definidas como mapas inmutables de Dart en el archivo `lib/features/dnd/domain/rules/constants.dart`. 
Las pantallas bestiary_page.dart y spells_page.dart consultan estas constantes locales, lo que permite filtrados instantáneos sin consumo de cuota de lecturas de Firestore.
```dart
// Fragmento de lib/features/dnd/domain/rules/constants.dart
const int pointBuyBudget = 27;
const Map<int, int> pointBuyCost = { 8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9 };

final Map<String, Map<String, dynamic>> races = {
  'Elfo': { 'i': 'Visión Oscura, Sentidos Agudos...', 'subraces': { ... } },
  'Tiefling': { 'i': 'Visión Oscura y Resistencia Infernal.', ... },
};
```

**Seed Service (Bootstrap):**
Para poblar la base de datos con los catálogos iniciales (música, noticias), se implementó `lib/app/bootstrap_seed_service.dart`. Este servicio comprueba el documento app_meta/bootstrap en Firestore y, si es la primera vez que un administrador entra, lee los archivos locales assets/musica.json y assets/noticias.json para insertarlos en las colecciones globales mediante transacciones seguras.

### 7.3. Módulo de Música y Noticias
El reproductor se mantiene vivo durante toda la aplicación. El AudioPlayer de just_audio se inyecta como un singleton a través de un AudioProvider en la raíz del árbol de widgets. El módulo de noticias utiliza el paquete xml para parsear feeds RSS externos importados por el administrador.

### 7.4. Panel de Administración
El panel permite enviar notificaciones push. El administrador redacta el mensaje en la app, que escribe un documento en la colección admin_broadcasts. Una Cloud Function detecta ese nuevo documento y usa el Admin SDK para enviar la notificación vía FCM, manteniendo la clave del servidor segura en el backend.

---

## 8. Base de datos y Firebase

### 8.1. Estructura de colecciones
**Colecciones globales:** users, usernames, admin_emails, songs, news, admin_broadcasts, app_meta, recovery_status.
**Subcolecciones por usuario (/users/{uid}/...):** notes, characters, playlist, news_favorites, fcmTokens, known_spells.

### 8.2. Reglas de seguridad
Las reglas de Firestore son el núcleo de la seguridad. Se han definido funciones auxiliares para evitar la duplicación de lógica y garantizar que el email se compare siempre en minúsculas:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function emailLower() {
      return signedIn() && request.auth.token.email is string
          ? request.auth.token.email.lower()
          : '';
    }
    function isAdmin() {
      return signedIn()
          && exists(/databases/$(database)/documents/admin_emails/$(emailLower()))
          && get(/databases/$(database)/documents/admin_emails/$(emailLower())).data.enabled == true;
    }
    function userActive(uid) {
      return exists(/databases/$(database)/documents/users/$(uid))
          && get(/databases/$(database)/documents/users/$(uid)).data.isActive == true;
    }
    // Ejemplo de aplicación:
    match /users/{uid} { 
      allow read, write: if (self(uid) && userActive(uid)) || isAdmin(); 
    }
  }
}
```

### 8.3. Cloud Functions
En la carpeta functions/ se han desplegado dos funciones críticas en Node.js usando el Admin SDK:
1. **cleanupUnverifiedAuthUsers:** Una función programada (onSchedule) que se ejecuta cada 24 horas en la región europe-west1. Itera sobre todos los usuarios de Firebase Auth paginando de 1000 en 1000, y elimina mediante admin.auth().deleteUser() aquellos que se registraron con email/password, no han verificado su correo y llevan más de 24 horas inactivos.
2. **cleanupFirestoreUserDataOnAuthDelete:** Un trigger reactivo (onUserDeleted) que escucha el evento de borrado de un usuario en Auth. Cuando un administrador elimina una cuenta, esta función se dispara automáticamente para borrar el documento en /users/{uid} y limpiar las referencias en la colección /usernames, evitando datos huérfanos en Firestore.

---

## 9. Seguridad
El modelo de amenazas asume que el cliente (la app Flutter) está comprometido. Por tanto, ninguna regla de negocio crítica depende del código Dart. 
- **Aislamiento:** Las notas y personajes están en subcolecciones de /users/{uid}. La regla allow read, write: if self(uid) garantiza que un usuario solo puede acceder a su propio UID.
- **Inmutabilidad de roles:** Un usuario normal puede actualizar su displayName, pero las reglas de Firestore bloquean cualquier update que intente modificar el campo isActive o isAdmin. Solo el panel de administración puede cambiar esos campos.

---

## 10. Rendimiento y optimización
El mayor reto de rendimiento fue la carga inicial del Bestiario. Parsear un JSON de miles de monstruos en el main isolate (el hilo principal de la UI) causaba dropped frames. 
**Solución:** Se optó por empaquetar los datos como constantes de Dart (constants.dart), eliminando por completo la necesidad de parseo en tiempo de ejecución o llamadas a red para el catálogo base. Para los datos que sí requieren caché dinámico, se utiliza Hive, cuyo acceso síncrono en microsegundos contribuye a tiempos de carga de pantalla inferiores a los de una consulta de red.

---

## 11. Testing
Se han escrito Widget Tests para los componentes críticos. Dado que Firebase no puede conectarse a internet en los tests unitarios, se han creado mocks (clases falsas) de los Services. Por ejemplo, el MockAuthService simula un login exitoso o fallido para verificar que la UI muestra los SnackBar de error correctamente sin depender de los servidores de Google.

---

## 12. Problemas encontrados
1. **Sincronización de tokens:** Firebase Auth no actualiza el claim email_verified en el token local hasta que se hace reload(). Solución: polling en la pantalla de verificación.
2. **Cloud Functions y plan Spark:** Las funciones programadas requieren el plan Blaze. Solución temporal: implementar la limpieza de cuentas como tarea manual ejecutable desde el panel de administración, reservando la función automática para producción.
3. **Dependencias locales:** El paquete flutter_app_badger no era compatible en pub.dev, por lo que se incluyó como dependencia de ruta local en third_party/, requiriendo ajustes en la configuración del monorepo.

---

## 13. Resultados
La aplicación compila correctamente para Android e iOS. Se han implementado los requisitos funcionales definidos. El catálogo de Bestiario y Grimorio carga en menos de 0.1 segundos gracias a las constantes de Dart, y el sistema de roles bloquea eficazmente a usuarios no verificados o baneados a nivel de base de datos.

---

## 14. Líneas futuras
1. Activar el plan Blaze de Firebase para desplegar completamente la Cloud Function de limpieza automática.
2. Implementar la generación de fichas de personaje en PDF exportable usando el paquete pdf.
3. Mover el estado isActive a los Custom Claims del token de Firebase Auth para evitar que las reglas de Firestore tengan que leer un documento extra en cada petición, reduciendo costes.
4. Añadir soporte offline bidireccional completo con la persistencia nativa de Firestore.

---

## 15. Conclusiones
El desarrollo de La Taberna del Búho ha demostrado que Flutter y Firebase son herramientas extremadamente productivas, pero requieren un diseño de seguridad riguroso. El mayor aprendizaje técnico ha sido comprender que la seguridad en el cliente es ilusoria: las reglas de Firestore son el único muro real entre los datos y un atacante. 

Además, la decisión de empaquetar los catálogos pesados (Bestiario/Grimorio) como constantes de Dart inmutables, en lugar de depender de bases de datos locales o llamadas a red, ha sido clave para que la aplicación ofrezca una experiencia de usuario fluida, con latencia cero y totalmente funcional sin conexión.

---

## 16. Bibliografía
- Documentación oficial de Flutter y Dart (flutter.dev, dart.dev).
- Documentación de Firebase (Firestore, Auth, Cloud Functions).
- Documentación de Hive (docs.hivedb.dev) para implementación de TypeAdapters.
- Martin, R. C. (2017). Clean Architecture: A Craftsman's Guide to Software Structure and Design. Prentice Hall.

---

## 17. Anexos

### Anexo A — Diagrama de flujo de Autenticación
```text
  [Inicio App]
  │
  [¿Usuario autenticado?]
   NO  ──►  [LoginScreen]  ──►  [Registro?]
  │  SÍ
                          [Crear cuenta Firebase Auth]
  │
                          [Enviar email verificación]
  │
   SÍ  ◄──  [¿Email verificado?]  ◄──  [Polling user.reload()]
  │  SÍ
          [¿Doc usuario existe en Firestore?]
  │  NO
          [Crear documento /users/{uid}]
  │
          [¿isActive == true?]
  │  SÍ
          [HomeScreen]  ──►  [¿isAdmin?]  ──►  [AdminPanel]
```

