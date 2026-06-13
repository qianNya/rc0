import 'script_scene.dart';

/// 幕 — 剧本大段落
class ScriptAct {
  const ScriptAct({
    required this.id,
    required this.orderIndex,
    required this.title,
    this.synopsis = '',
    this.scenes = const [],
  });

  final String id;
  final int orderIndex;
  final String title;
  final String synopsis;
  final List<ScriptScene> scenes;

  int get sceneCount => scenes.length;

  int get frameCount =>
      scenes.fold(0, (sum, scene) => sum + scene.frameCount);

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderIndex': orderIndex,
        'title': title,
        'synopsis': synopsis,
        'scenes': scenes.map((s) => s.toJson()).toList(),
      };

  factory ScriptAct.fromJson(Map<String, dynamic> json) {
    return ScriptAct(
      id: json['id'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String? ?? '',
      scenes: (json['scenes'] as List<dynamic>?)
              ?.map((e) => ScriptScene.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  ScriptAct copyWith({
    String? id,
    int? orderIndex,
    String? title,
    String? synopsis,
    List<ScriptScene>? scenes,
  }) {
    return ScriptAct(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      scenes: scenes ?? this.scenes,
    );
  }
}
