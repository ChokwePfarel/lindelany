import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Crops [original] image file to a centered 1:1 square, optionally resizes
/// (downscales) to [maxSide] px, and encodes to JPEG at [quality] (0-100).
/// Returns a **new temp File**; original is untouched.
Future<File> cropToSquareJpeg(
    File original, {
      int? maxSide,         // e.g. 1080 to save bandwidth; null = keep size
      int quality = 85,
    }) async {
  final bytes = await original.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Unsupported or corrupt image: ${original.path}');
  }

  final side = math.min(decoded.width, decoded.height);
  final x = ((decoded.width - side) / 2).round();
  final y = ((decoded.height - side) / 2).round();

  img.Image square = img.copyCrop(decoded, x: x, y: y, width: side, height: side);

  if (maxSide != null && side > maxSide) {
    square = img.copyResize(square, width: maxSide, height: maxSide); // stays square
  }

  final jpgBytes = img.encodeJpg(square, quality: quality);

  final tmpDir = await getTemporaryDirectory();
  final outPath = p.join(
    tmpDir.path,
    'sq_${DateTime.now().millisecondsSinceEpoch}_${p.basename(original.path)}.jpg',
  );
  final outFile = File(outPath);
  await outFile.writeAsBytes(jpgBytes, flush: true);
  return outFile;
}
