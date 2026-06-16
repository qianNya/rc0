import '../pose_item.dart';
import 'screenplay.dart';
import 'script_act.dart';
import 'script_frame.dart';
import 'script_scene.dart';

enum ExploreFeedType { script, template }

extension ExploreFeedMapper on Screenplay {
  ExploreFeedType get exploreFeedType {
    if (isPublished && !isForkCopy && !isLocal) {
      return ExploreFeedType.template;
    }
    return ExploreFeedType.script;
  }
}

/// 网格卡片展示用轻量视图
class ScreenplayCardView {
  const ScreenplayCardView({
    required this.id,
    required this.title,
    required this.tags,
    required this.likes,
    required this.views,
    required this.favorites,
    required this.hierarchySummary,
    required this.author,
    required this.categoryLabel,
    required this.frameCount,
    this.coverImagePath,
    this.isLocal = false,
    this.commentCount = 0,
  });

  final String id;
  final String title;
  final List<String> tags;
  final int likes;
  final int views;
  final int favorites;
  final String hierarchySummary;
  final String author;
  final String categoryLabel;
  final int frameCount;
  final String? coverImagePath;
  final bool isLocal;
  final int commentCount;
}

extension ScreenplayCardMapper on Screenplay {
  ScreenplayCardView toCardView() {
    final tags = allTags;
    return ScreenplayCardView(
      id: id,
      title: title,
      tags: tags,
      likes: likes,
      views: views,
      favorites: favorites,
      hierarchySummary: hierarchySummary,
      author: author,
      categoryLabel: tags.isNotEmpty ? tags.first : '人像构图',
      frameCount: frameCount,
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
        localImagePath: pose.imagePaths[i],
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
        localImagePath: pose.coverImagePath!,
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
