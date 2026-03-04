import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageUtils {
  ImageUtils._();

  static Future<Uint8List?> resizeImage(
    File imageFile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final resized = img.copyResize(
      decoded,
      width: decoded.width > maxWidth ? maxWidth : decoded.width,
      height: decoded.height > maxHeight ? maxHeight : decoded.height,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
