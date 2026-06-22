import '../../screenplay/data/screenplay-api.dart';

class FrameDownloadResp {
  final String downloadUrl;
  final num expireSec;

  FrameDownloadResp({required this.downloadUrl, required this.expireSec});

  factory FrameDownloadResp.fromJson(Map<String, dynamic> m) {
    return FrameDownloadResp(
      downloadUrl: m['download_url'] ?? '',
      expireSec: m['expire_sec'] ?? 0,
    );
  }
}

class FrameDetailResp {
  final Frame frame;
  final num acgnImageId;

  FrameDetailResp({required this.frame, required this.acgnImageId});

  factory FrameDetailResp.fromJson(Map<String, dynamic> m) {
    return FrameDetailResp(
      frame: Frame.fromJson(m),
      acgnImageId: m['acgn_image_id'] ?? 0,
    );
  }
}

class ListSceneFramesResp {
  final List<Frame> list;
  final num total;

  ListSceneFramesResp({required this.list, required this.total});

  factory ListSceneFramesResp.fromJson(Map<String, dynamic> m) {
    return ListSceneFramesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Frame.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
}
