class VideoQualityUrls {
  final int quality;
  final String url;

  VideoQualityUrls({
    required this.quality,
    required this.url,
  });

  factory VideoQualityUrls.fromJson(Map<String, dynamic> json) => VideoQualityUrls(
        quality: json['quality'] as int,
        url: json['url'] as String,
      );

  Map<String, dynamic> toJson() => {
        'quality': quality,
        'url': url,
      };

  @override
  String toString() => 'VideoQualityUrls(quality: $quality, url: $url)';
}
