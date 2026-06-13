import '../pose_item.dart';
import 'screenplay.dart';
import 'script_act.dart';
import 'script_frame.dart';
import 'script_scene.dart';

/// 网格卡片展示用轻量视图
class ScreenplayCardView {
  const ScreenplayCardView({
    required this.id,
    required this.title,
    required this.tags,
    required this.likes,
    required this.views,
    required this.hierarchySummary,
    this.coverImagePath,
    this.isLocal = false,
  });

  final String id;
  final String title;
  final List<String> tags;
  final int likes;
  final int views;
  final String hierarchySummary;
  final String? coverImagePath;
  final bool isLocal;
}

extension ScreenplayCardMapper on Screenplay {
  ScreenplayCardView toCardView() {
    return ScreenplayCardView(
      id: id,
      title: title,
      tags: allTags,
      likes: likes,
      views: views,
      hierarchySummary: hierarchySummary,
      coverImagePath: coverImagePath,
      isLocal: isLocal,
    );
  }
}

Screenplay migrateFromPoseItem(PoseItem pose) {
  final frames = <ScriptFrame>[];
  for (var i = 0; i < pose.imagePaths.length; i++) {
    frames.add(
      ScriptFrame(
        id: '${pose.id}-frame-$i',
        orderIndex: i,
        imagePath: pose.imagePaths[i],
        caption: pose.description,
        tags: pose.tags,
      ),
    );
  }

  if (frames.isEmpty && pose.coverImagePath != null) {
    frames.add(
      ScriptFrame(
        id: '${pose.id}-frame-0',
        orderIndex: 0,
        imagePath: pose.coverImagePath!,
        caption: pose.description,
        tags: pose.tags,
      ),
    );
  }

  return Screenplay(
    id: pose.id,
    title: pose.title,
    synopsis: pose.description,
    tags: pose.tags,
    author: pose.author,
    authorBio: pose.authorBio,
    likes: pose.likes,
    views: pose.views,
    favorites: pose.favorites,
    isLocal: pose.isLocal,
    createdAt: pose.createdAt,
    acts: [
      ScriptAct(
        id: '${pose.id}-act-0',
        orderIndex: 0,
        title: '第一幕',
        synopsis: '',
        scenes: [
          ScriptScene(
            id: '${pose.id}-scene-0',
            orderIndex: 0,
            title: '第一场',
            description: pose.description,
            frames: frames,
          ),
        ],
      ),
    ],
  );
}
