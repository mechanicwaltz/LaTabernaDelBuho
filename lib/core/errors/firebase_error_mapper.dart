import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  static String fromObject(Object error) {
    if (error is FirebaseAuthException) {
      return fromAuth(error);
    }
    if (error is FirebaseException) {
      if (error.plugin == 'cloud_firestore') {
        return fromFirestore(error);
      }
      if (error.plugin == 'firebase_storage') {
        return fromStorage(error);
      }
      return error.message ?? 'Error de Firebase';
    }
    return 'Ha ocurrido un error inesperado';
  }

  static String fromAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electronico no tiene un formato valido.';
      case 'user-disabled':
        return 'Esta cuenta esta deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya esta registrado.';
      case 'weak-password':
        return 'La contrasena es demasiado debil.';
      case 'too-many-requests':
        return 'Demasiados intentos. Prueba de nuevo mas tarde.';
      case 'operation-not-allowed':
        return 'El acceso por correo y contrasena no esta habilitado en Firebase.';
      case 'requires-recent-login':
        return 'Necesitas volver a iniciar sesion para completar esta accion.';
      default:
        return e.message ?? 'Error de autenticacion';
    }
  }

  static String fromFirestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'No tienes permisos para esta operacion.';
      case 'not-found':
        return 'No se encontro el documento solicitado.';
      case 'already-exists':
        return 'Ese recurso ya existe.';
      case 'unavailable':
        return 'Servicio no disponible temporalmente.';
      default:
        return e.message ?? 'Error de base de datos';
    }
  }

  static String fromStorage(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'No tienes permisos para subir o leer este archivo.';
      case 'canceled':
        return 'La operacion se cancelo.';
      case 'bucket-not-found':
        return 'Firebase Storage no esta configurado. Activalo en Firebase Console > Storage > Comenzar.';
      case 'object-not-found':
        return 'No se encontro el archivo en almacenamiento.';
      default:
        final msg = (e.message ?? '').toLowerCase();
        if (msg.contains('storage has not been set up') ||
            msg.contains('requested entity was not found')) {
          return 'Firebase Storage no esta configurado. Activalo en Firebase Console > Storage > Comenzar.';
        }
        return e.message ?? 'Error de almacenamiento';
    }
  }
}
