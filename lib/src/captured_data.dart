import 'dart:typed_data';

class CapturedData {
  String? imagePath;
  int? imageWidth;
  int? imageHeight;
  String? base64Image;
  Uint8List? pngBytes;

  CapturedData({
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.base64Image,
    this.pngBytes,
  });

  factory CapturedData.fromJson(Map<String, dynamic> json) {
    return CapturedData(
      imagePath: json['imagePath'],
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
      base64Image: json['base64Image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'base64Image': base64Image,
    }..removeWhere((key, value) => value == null);
  }
}
