import 'script_frame.dart';

/// 场 — 拍摄场景单元
class ScriptScene {
  const ScriptScene({
    required this.id,
    required this.orderIndex,
    required this.title,
    this.location = '',
    this.timeOfDay = '',
    this.description = '',
    this.frames = const [],
  });

  final String id;
  final int orderIndex;
  final String title;
  final String location;
  final String timeOfDay;
  final String description;
  final List<ScriptFrame> frames;

  int get frameCount => frames.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderIndex': orderIndex,
        'title': title,
        'location': location,
        'timeOfDay': timeOfDay,
        'description': description,
        'frames': frames.map((f) => f.toJson()).toList(),
      };

  factory ScriptScene.fromJson(Map<String, dynamic> json) {
    return ScriptScene(
      id: json['id'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
      title: json['title'] as String,
      location: json['location'] as String? ?? '',
      timeOfDay: json['timeOfDay'] as String? ?? '',
      description: json['description'] as String? ?? '',
      frames: (json['frames'] as List<dynamic>?)
              ?.map((e) => ScriptFrame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  ScriptScene copyWith({
    String? id,
    int? orderIndex,
    String? title,
    String? location,
    String? timeOfDay,
    String? description,
    List<ScriptFrame>? frames,
  }) {
    return ScriptScene(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
      title: title ?? this.title,
      location: location ?? this.location,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      description: description ?? this.description,
      frames: frames ?? this.frames,
    );
  }
}
