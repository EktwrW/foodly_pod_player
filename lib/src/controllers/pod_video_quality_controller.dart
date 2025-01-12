part of 'pod_getx_video_controller.dart';

class _PodVideoQualityController extends _PodVideoController {
  ///
  int? vimeoPlayingVideoQuality;

  ///vimeo all quality urls
  List<VideoQualityUrls> vimeoOrVideoUrls = [];
  late String _videoQualityUrl;

  ///invokes callback from external controller
  VoidCallback? onVimeoVideoQualityChanged;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getQualityUrlsFromVimeoId(
    String videoId, {
    String? hash,
  }) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final vimeoVideoUrls = await VideoApis.getVimeoVideoQualityUrls(
        videoId,
        hash,
      );

      ///
      vimeoOrVideoUrls = vimeoVideoUrls ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getQualityUrlsFromVimeoPrivateId(
    String videoId,
    Map<String, String> httpHeader,
  ) async {
    try {
      podVideoStateChanger(PodVideoState.loading);
      final vimeoVideoUrls = await VideoApis.getVimeoPrivateVideoQualityUrls(videoId, httpHeader);

      ///
      vimeoOrVideoUrls = vimeoVideoUrls ?? [];
    } catch (e) {
      rethrow;
    }
  }

  void sortQualityVideoUrls(List<VideoQualityUrls>? urls) {
    // Imprimir estado inicial de la lista
    podLog('Estado inicial de URLs: ${urls?.length ?? 0}');

    if (urls == null || urls.isEmpty) {
      podLog('ADVERTENCIA: Lista de URLs vacía o nula');
      return;
    }

    // Imprimir todas las calidades antes de filtrar
    podLog('Calidades antes de filtrar: ${urls.map((e) => e.quality).toList()}');

    // Filtrar calidades problemáticas
    urls.removeWhere((element) {
      bool remove = element.quality == 240 || (kIsWeb && element.quality == 144);

      if (remove) {
        podLog('Removiendo calidad: ${element.quality}');
      }
      return remove;
    });

    // Ordenar por calidad
    try {
      urls.sort((a, b) => a.quality.compareTo(b.quality));
    } catch (e) {
      podLog('Error al ordenar: $e');
    }

    // Imprimir calidades después de filtrar y ordenar
    podLog('Calidades después de filtrar: ${urls.map((e) => e.quality).toList()}');

    // Verificar si quedaron URLs
    if (urls.isEmpty) {
      podLog('CRÍTICO: No quedaron URLs después de filtrar');
    }

    vimeoOrVideoUrls = urls;
  }

  ///get vimeo quality `ex: 1080p` url
  VideoQualityUrls getQualityUrl(int quality) {
    return vimeoOrVideoUrls.firstWhere(
      (element) => element.quality == quality,
      orElse: () => vimeoOrVideoUrls.first,
    );
  }

  Future<String> getUrlFromVideoQualityUrls({
    required List<int> qualityList,
    required List<VideoQualityUrls> videoUrls,
  }) async {
    sortQualityVideoUrls(videoUrls);
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }

    final fallback = vimeoOrVideoUrls[0];
    VideoQualityUrls? urlWithQuality;
    for (final quality in qualityList) {
      urlWithQuality = vimeoOrVideoUrls.firstWhere(
        (url) => url.quality == quality,
        orElse: () => fallback,
      );

      if (urlWithQuality != fallback) {
        break;
      }
    }

    urlWithQuality ??= fallback;
    _videoQualityUrl = urlWithQuality.url;
    vimeoPlayingVideoQuality = urlWithQuality.quality;
    return _videoQualityUrl;
  }

  Future<List<VideoQualityUrls>> getVideoQualityUrlsFromYoutube(
    String youtubeIdOrUrl,
    bool live,
  ) async {
    final yt = YoutubeExplode();
    try {
      podLog('Intentando obtener video: $youtubeIdOrUrl');

      final video = await yt.videos.get(youtubeIdOrUrl);
      podLog('Video obtenido: ${video.title}');

      final manifest = await yt.videos.streams.getManifest(youtubeIdOrUrl);
      podLog('Manifest obtenido');

      final qualityMap = {
        VideoQuality.low144: 144,
        VideoQuality.low240: 240,
        VideoQuality.medium360: 360,
        VideoQuality.medium480: 480,
        VideoQuality.high720: 720,
        VideoQuality.high1080: 1080,
        VideoQuality.high1440: 1440,
        VideoQuality.high2160: 2160,
      };

      final List<StreamInfo> allStreams = [...manifest.muxed, ...manifest.videoOnly];

      podLog('Número total de streams: ${allStreams.length}');

      final urls = <VideoQualityUrls>[];

      for (final element in allStreams) {
        int quality = 0;

        if (element is MuxedStreamInfo) {
          quality = qualityMap[element.videoQuality] ?? 0;
        } else if (element is VideoOnlyStreamInfo) {
          quality = qualityMap[element.videoQuality] ?? 0;
        }

        if (quality > 0) {
          final url = element.url.toString();

          podLog('Stream válido - Calidad: $quality, URL: $url');

          urls.add(
            VideoQualityUrls(
              quality: quality,
              url: url,
            ),
          );
        }
      }

      podLog('URLs encontradas: ${urls.length}');

      yt.close();

      if (urls.isEmpty) {
        // Fallback a URL de embedding si no se encuentran streams
        final videoId = youtubeIdOrUrl.contains('youtube.com')
            ? RegExp(r'v=([^&]+)').firstMatch(youtubeIdOrUrl)?.group(1)
            : youtubeIdOrUrl;

        if (videoId != null) {
          urls.add(
            VideoQualityUrls(
              quality: 0,
              url: 'https://www.youtube.com/embed/$videoId',
            ),
          );
        }
      }

      return urls;
    } catch (e) {
      podLog('Error detallado al obtener URLs: $e');

      // Fallback a URL de embedding en caso de error
      final videoId = youtubeIdOrUrl.contains('youtube.com')
          ? RegExp(r'v=([^&]+)').firstMatch(youtubeIdOrUrl)?.group(1)
          : youtubeIdOrUrl;

      if (videoId != null) {
        return [
          VideoQualityUrls(
            quality: 0,
            url: 'https://www.youtube.com/embed/$videoId',
          ),
        ];
      }

      rethrow;
    }
  }

  Future<void> changeVideoQuality(int? quality) async {
    if (vimeoOrVideoUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    if (vimeoPlayingVideoQuality != quality) {
      _videoQualityUrl = vimeoOrVideoUrls.where((element) => element.quality == quality).first.url;
      podLog(_videoQualityUrl);
      vimeoPlayingVideoQuality = quality;
      _videoCtr?.removeListener(videoListner);
      podVideoStateChanger(PodVideoState.paused);
      podVideoStateChanger(PodVideoState.loading);
      playingVideoUrl = _videoQualityUrl;
      _videoCtr = VideoPlayerController.networkUrl(Uri.parse(_videoQualityUrl));
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      _videoCtr?.addListener(videoListner);
      await _videoCtr?.seekTo(_videoPosition);
      setVideoPlayBack(_currentPaybackSpeed);
      podVideoStateChanger(PodVideoState.playing);
      onVimeoVideoQualityChanged?.call();
      update();
      update(['update-all']);
    }
  }
}
