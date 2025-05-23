

// Process image to make it square 1000x1000 max
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> processImageToSquare(String imagePath) async {
  // Read the file
  final file = File(imagePath);
  final bytes = await file.readAsBytes();
  final original = img.decodeImage(bytes);
  
  if (original == null) return imagePath;
  
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
  
  // Save the processed image
  final tempDir = await getTemporaryDirectory();
  final processedPath = path.join(tempDir.path, 'processed_${path.basename(imagePath)}');
  final processedFile = File(processedPath);
  await processedFile.writeAsBytes(img.encodeJpg(resized, quality: 90));
  
  return processedPath;
}
