import 'dart:io';
import 'dart:convert';

void main() async {
  // 1x1 Transparent PNG
  final String transparentPngBase64 =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

  // 1x1 Cream/Paper Color PNG (Approx #FFFBE8)
  // Replaced with a simple white pixel for safety if hex encoding is complex manual work.
  // Actually, I'll use a known valid base64 for a white pixel, tinting handles color.
  final String whitePngBase64 =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==";

  final File headerPattern = File('assets/images/surah_header_pattern.png');
  final File paperTexture = File('assets/images/paper_texture.png');

  if (!await headerPattern.exists()) {
    await headerPattern.create(recursive: true);
    await headerPattern.writeAsBytes(base64Decode(transparentPngBase64));
    print('Created surah_header_pattern.png');
  } else {
    print('surah_header_pattern.png already exists');
  }

  if (!await paperTexture.exists()) {
    await paperTexture.create(recursive: true);
    await paperTexture.writeAsBytes(base64Decode(whitePngBase64));
    print('Created paper_texture.png');
  } else {
    print('paper_texture.png already exists');
  }
}
