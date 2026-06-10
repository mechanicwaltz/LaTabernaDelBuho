# 🦉 La Taberna del Búho

[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**La Taberna del Búho** es una aplicación móvil multiplataforma desarrollada en Flutter como Trabajo de Fin de Grado (TFG). Diseñada como la herramienta definitiva para jugadores de rol de fantasía, permite consultar bestiarios, gestionar grimorios de hechizos y organizar las notas de campaña, todo sincronizado en la nube y con soporte para modo offline.

---

## ✨ Características Principales

- 📖 **Bestiario y Grimorio:** Catálogos interactivos y detallados de monstruos y hechizos, con búsqueda y filtrado avanzado.
- ☁️ **Sincronización en la Nube:** Integración con **Firebase Firestore** y **Authentication** para que el jugador pueda acceder a sus personajes, notas y progreso desde cualquier dispositivo.
- 📴 **Modo Offline (First-Offline):** Gracias a **Hive**, los datos esenciales del bestiario y grimorio se almacenan localmente, permitiendo su uso sin conexión a internet (ideal para jugar en sótanos o zonas sin cobertura).
- 🔔 **Notificaciones y Recordatorios:** Sistema de alertas locales y push (**Firebase Cloud Messaging**) para recordar sesiones de juego, tiempos de recarga de hechizos o eventos de la campaña.
- 🎨 **Multimedia e Inmersión:** Soporte para reproducir efectos de sonido ambiente (`just_audio`), visualizar gifs y gestionar imágenes de los personajes o mapas.
- 💰 **Monetización:** Integración limpia y no intrusiva con **Google Mobile Ads**.

---

## 🛠️ Tecnologías y Arquitectura

El proyecto sigue una arquitectura limpia, utilizando **Provider** para la gestión del estado y separando claramente la lógica de negocio de la interfaz de usuario.

### Stack Principal
- **Frontend:** Flutter (Dart)
- **Backend / BaaS:** Firebase (Core, Auth, Firestore, Messaging)
- **Gestión de Estado:** Provider
- **Base de Datos Local:** Hive & Hive Flutter
- **Inyección de Dependencias / Utilidades:** GetIt / Provider (ajustar si usas otro)

### Dependencias Destacadas
| Categoría | Paquetes |
| :--- | :--- |
| **Backend & Cloud** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` |
| **Estado & Datos** | `provider`, `hive`, `hive_flutter`, `shared_preferences` |
| **Multimedia** | `just_audio`, `image_picker`, `flutter_gif`, `image` |
| **UI & Utilidades** | `google_fonts`, `flutter_local_notifications`, `permission_handler`, `url_launcher` |

---

## 🚀 Instalación y Configuración

Para compilar y ejecutar este proyecto localmente, necesitas tener el SDK de Flutter instalado (versión 3.3.0 o superior).

### 1. Clonar el repositorio
```bash
git clone https://github.com/mechanicwaltz/LaTabernaDelBuho.git
cd LaTabernaDelBuho
