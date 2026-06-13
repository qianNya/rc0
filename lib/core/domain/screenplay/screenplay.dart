import 'script_act.dart';
import 'script_frame.dart';

/// 剧本 — 完整发布单元
class Screenplay {
  const Screenplay({
    required this.id,
    required this.title,
    this.synopsis = '',
    this.tags = const [],
    this.author = '我',
    this.authorBio = '摄影创作者',
    this.likes = 0,
    this.views = 0,
    this.favorites = 0,
    this.acts = const [],
    this.isLocal = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String synopsis;
  final List<String> tags;
  final String author;
  final String authorBio;
  final int likes;
  final int views;
  final int favorites;
  final List<ScriptAct> acts;
  final bool isLocal;
  final DateTime? createdAt;

  int get actCount => acts.length;

  int get sceneCount =>
      acts.fold(0, (sum, act) => sum + act.sceneCount);

  int get frameCount =>
      acts.fold(0, (sum, act) => sum + act.frameCount);

  String? get coverImagePath {
    for (final act in acts) {
      for (final scene in act.scenes) {
        for (final frame in scene.frames) {
          if (frame.imagePath.isNotEmpty) {
            return frame.imagePath;
          }
        }
      }
    }
    return null;
  }

  String get hierarchySummary => '$actCount幕 · $sceneCount场 · $frameCount画';

  List<ScriptFrame> get allFrames {
    final frames = <ScriptFrame>[];
    for (final act in acts) {
      for (final scene in act.scenes) {
        frames.addAll(scene.frames);
      }
    }
    return frames;
  }

  List<String> get allTags {
    final set = <String>{...tags};
    for (final frame in allFrames) {
      set.addAll(frame.tags);
    }
    return set.toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'synopsis': synopsis,
        'tags': tags,
        'author': author,
        'authorBio': authorBio,
        'likes': likes,
        'views': views,
        'favorites': favorites,
        'acts': acts.map((a) => a.toJson()).toList(),
        'isLocal': isLocal,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Screenplay.fromJson(Map<String, dynamic> json) {
    return Screenplay(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      author: json['author'] as String? ?? '我',
      authorBio: json['authorBio'] as String? ?? '摄影创作者',
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
      acts: (json['acts'] as List<dynamic>?)
              ?.map((e) => ScriptAct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLocal: json['isLocal'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Screenplay copyWith({
    String? id,
    String? title,
    String? synopsis,
    List<String>? tags,
    String? author,
    String? authorBio,
    int? likes,
    int? views,
    int? favorites,
    List<ScriptAct>? acts,
    bool? isLocal,
    DateTime? createdAt,
  }) {
    return Screenplay(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      authorBio: authorBio ?? this.authorBio,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      acts: acts ?? this.acts,
      isLocal: isLocal ?? this.isLocal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
