class PersonImage {
  final String? filePath;
  final double? aspectRatio;
  final int? width;
  final int? height;

  PersonImage({
    this.filePath,
    this.aspectRatio,
    this.width,
    this.height,
  });

  factory PersonImage.fromJson(Map<String, dynamic> json) {
    return PersonImage(
      filePath: json['file_path'],
      aspectRatio: json['aspect_ratio']?.toDouble(),
      width: json['width'],
      height: json['height'],
    );
  }
}