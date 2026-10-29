// Process image to make it square 1000x1000 max
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Crops to a centered square, resizes to 1000x1000 and re-encodes as JPEG.
// Photos are public once uploaded, so all metadata is dropped: phone photos usually carry
// EXIF GPS coordinates, timestamps and device details. Orientation is applied to the pixels
// first so the photo still displays the right way up without its EXIF orientation tag.
// Returns null if the bytes aren't a decodable image.
Uint8List? squareImageWithoutMetadata(Uint8List bytes) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    // Some decoders throw on corrupt / unsupported data instead of returning null
    return null;
  }
  if (decoded == null) return null;

  final original = img.bakeOrientation(decoded);

  // Crop to square
  final size = original.width < original.height ? original.width : original.height;
  final xOffset = (original.width - size) ~/ 2;
  final yOffset = (original.height - size) ~/ 2;

  final square = img.copyCrop(
    original,
    x: xOffset,
    y: yOffset,
    width: size,
    height: size
  );

  // Resize to 1000x1000
  final resized = img.copyResize(square, width: 1000, height: 1000);

  // Remove all metadata before encoding
  resized.exif = img.ExifData();
  resized.iccProfile = null;
  resized.textData = null;

  return img.encodeJpg(resized, quality: 90);
}

// Returns the path of the processed image, or null if the file couldn't be read as an image
// (in which case nothing should be uploaded).
Future<String?> processImageToSquare(String imagePath) async {
  if (imagePath.isEmpty) return null;

  final processed = squareImageWithoutMetadata(await File(imagePath).readAsBytes());
  if (processed == null) return null;

  // Save the processed image
  final tempDir = await getTemporaryDirectory();
  final processedPath = path.join(tempDir.path, 'processed_${path.basenameWithoutExtension(imagePath)}.jpg');
  await File(processedPath).writeAsBytes(processed);

  return processedPath;
}
