import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> requestAudioPermissions() async {
    // Pedir micrófono
    var micStatus = await Permission.microphone.request();
    // Pedir manejo de audio
    var audioStatus = await Permission.speech.request();

    if (micStatus.isGranted && audioStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
