import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

class ProfileImageService {
  const ProfileImageService();

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    if (uid.trim().isEmpty) {
      throw StateError('Usuario invalido para actualizar la foto.');
    }

    final rawBytes = await file.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw StateError('No se pudo leer la imagen seleccionada.');
    }

    const maxSide = 512;
    img.Image processed = decoded;
    if (decoded.width > maxSide || decoded.height > maxSide) {
      final scale = decoded.width >= decoded.height
          ? maxSide / decoded.width
          : maxSide / decoded.height;
      final targetWidth = (decoded.width * scale).round();
      final targetHeight = (decoded.height * scale).round();
      processed = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    var quality = 78;
    var jpgBytes = img.encodeJpg(processed, quality: quality);
    while (jpgBytes.length > 380000 && quality > 48) {
      quality -= 8;
      jpgBytes = img.encodeJpg(processed, quality: quality);
    }

    final base64 = base64Encode(jpgBytes);
    return 'data:image/jpeg;base64,$base64';
  }
}
