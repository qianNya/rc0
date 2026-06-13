/// 画 — 单张参考图/分镜画面
class ScriptFrame {
  const ScriptFrame({
    required this.id,
    required this.orderIndex,
    required this.imagePath,
    this.caption = '',
    this.actionNote = '',
    this.tags = const [],
  });

  final String id;
  final int orderIndex;
  final String imagePath;
  final String caption;
  final String actionNote;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderIndex': orderIndex,
        'imagePath': imagePath,
        'caption': caption,
        'actionNote': actionNote,
        'tags': tags,
      };

  factory ScriptFrame.fromJson(Map<String, dynamic> json) {
    return ScriptFrame(
      id: json['id'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
      imagePath: json['imagePath'] as String,
      caption: json['caption'] as String? ?? '',
      actionNote: json['actionNote'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  ScriptFrame copyWith({
    String? id,
    int? orderIndex,
    String? imagePath,
    String? caption,
    String? actionNote,
    List<String>? tags,
  }) {
    return ScriptFrame(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      actionNote: actionNote ?? this.actionNote,
      tags: tags ?? this.tags,
    );
  }
}
