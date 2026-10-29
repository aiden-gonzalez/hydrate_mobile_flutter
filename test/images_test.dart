import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrate_mobile_flutter/src/utils/images.dart';
import 'package:image/image.dart' as img;

void main() {
  group('squareImageWithoutMetadata', () {
    img.Image photoWithGps({int width = 1600, int height = 1200}) {
      final photo = img.Image(width: width, height: height);
      img.fill(photo, color: img.ColorRgb8(30, 144, 255));
      photo.exif.gpsIfd['GPSLatitude'] = img.IfdValueRational(40, 1);
      photo.exif.gpsIfd['GPSLongitude'] = img.IfdValueRational(86, 1);
      photo.exif.imageIfd['Make'] = img.IfdValueAscii('PhoneMaker');
      return photo;
    }

    test('fixture really has GPS metadata', () {
      final decoded = img.decodeJpg(img.encodeJpg(photoWithGps()))!;
      expect(decoded.exif.gpsIfd.isEmpty, isFalse);
    });

    test('produces a 1000x1000 JPEG with no EXIF metadata', () {
      final output = squareImageWithoutMetadata(img.encodeJpg(photoWithGps()))!;

      final decoded = img.decodeJpg(output)!;
      expect(decoded.width, 1000);
      expect(decoded.height, 1000);
      expect(decoded.exif.gpsIfd.isEmpty, isTrue);
      expect(decoded.exif.imageIfd.isEmpty, isTrue);
    });

    test('applies EXIF orientation to the pixels before dropping it', () {
      // A tall image tagged "rotate 90" should be treated as wide when picking the crop
      final photo = img.Image(width: 1200, height: 1600);
      img.fill(photo, color: img.ColorRgb8(0, 0, 0));
      photo.exif.imageIfd.orientation = 6;
      final output = squareImageWithoutMetadata(img.encodeJpg(photo))!;
      expect(img.decodeJpg(output)!.exif.imageIfd.hasOrientation, isFalse);
    });

    test('returns null for data that is not an image', () {
      expect(squareImageWithoutMetadata(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });
  });
}
