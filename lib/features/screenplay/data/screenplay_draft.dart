
import '../../upload/domain/upload_image_file.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../domain/shoot_params.dart';
import '../domain/cine_params.dart';
import 'screenplay_draft_tags.dart';

class FrameDraft {
  FrameDraft({
    required this.image,
    this.caption = '',
    this.actionNote = '',
    this.paramOverride,
    CineParams? cineParams,
    this.positivePrompt = '',
    this.negativePrompt = '',
    this.characterNote = '',
    this.characterId,
    this.characterName = '',
    this.poseId,
    Set<String>? tags,
    List<UploadImageFile>? referenceImages,
    this.lightingSchemeId,
    this.lightingRig,
    this.cineSetupId,
    this.cineSetup,
  })  : cineParams = cineParams ?? const CineParams(),
        tags = tags != null ? Set<String>.from(tags) : <String>{},
        referenceImages = referenceImages ?? [];

  UploadImageFile image;
  String caption;
  String actionNote;
  ShootParams? paramOverride;
  CineParams cineParams;
  String positivePrompt;
  String negativePrompt;
  String characterNote;
  int? characterId;
  String characterName;
  /// Optional link to a character-library pose (Roadmap: Pose Nodes).
  int? poseId;
  Set<String> tags;
  final List<UploadImageFile> referenceImages;
  String? lightingSchemeId;
  Map<String, dynamic>? lightingRig;
  String? cineSetupId;
  Map<String, dynamic>? cineSetup;

  FrameDraft copyDeep() {
    return FrameDraft(
      image: UploadImageFile(
        path: image.path,
        name: image.name,
        previewPath: image.previewPath,
      ),
      caption: caption,
      actionNote: actionNote,
      paramOverride: paramOverride?.copyWith(),
      cineParams: cineParams.copyWith(),
      positivePrompt: positivePrompt,
      negativePrompt: negativePrompt,
      characterNote: characterNote,
      characterId: characterId,
      characterName: characterName,
      poseId: poseId,
      tags: Set<String>.from(tags),
      referenceImages: [
        for (final ref in referenceImages)
          UploadImageFile(
            path: ref.path,
            name: ref.name,
            previewPath: ref.previewPath,
          ),
      ],
      lightingSchemeId: lightingSchemeId,
      lightingRig: lightingRig != null
          ? Map<String, dynamic>.from(lightingRig!)
          : null,
      cineSetupId: cineSetupId,
      cineSetup:
          cineSetup != null ? Map<String, dynamic>.from(cineSetup!) : null,
    );
  }
}

class SceneDraft {
  SceneDraft({
    this.title = '第一场',
    this.location = '',
    this.timeOfDay = '',
    this.weather = '',
    this.description = '',
    this.sceneLibraryId,
    this.sceneLibraryTitle = '',
    List<FrameDraft>? frames,
    this.paramOverride,
    Set<String>? tags,
    this.lightingSchemeId,
    this.lightingRig,
  })  : frames = frames ?? [],
        tags = tags != null ? Set<String>.from(tags) : <String>{};

  String title;
  String location;
  String timeOfDay;
  String weather;
  String description;
  String? sceneLibraryId;
  String sceneLibraryTitle;
  final List<FrameDraft> frames;
  ShootParams? paramOverride;
  Set<String> tags;
  String? lightingSchemeId;
  Map<String, dynamic>? lightingRig;

  SceneDraft copyDeep() {
    return SceneDraft(
      title: title,
      location: location,
      timeOfDay: timeOfDay,
      weather: weather,
      description: description,
      sceneLibraryId: sceneLibraryId,
      sceneLibraryTitle: sceneLibraryTitle,
      frames: frames.map((f) => f.copyDeep()).toList(),
      paramOverride: paramOverride?.copyWith(),
      tags: Set<String>.from(tags),
      lightingSchemeId: lightingSchemeId,
      lightingRig: lightingRig != null
          ? Map<String, dynamic>.from(lightingRig!)
          : null,
    );
  }
}

class ActDraft {
  ActDraft({
    this.title = '第一幕',
    this.synopsis = '',
    List<SceneDraft>? scenes,
    Set<String>? tags,
  })  : scenes = scenes ?? [SceneDraft()],
        tags = tags != null ? Set<String>.from(tags) : <String>{};

  String title;
  String synopsis;
  final List<SceneDraft> scenes;
  Set<String> tags;

  ActDraft copyDeep() {
    return ActDraft(
      title: title,
      synopsis: synopsis,
      scenes: scenes.map((s) => s.copyDeep()).toList(),
      tags: Set<String>.from(tags),
    );
  }
}

class ScreenplayCharacterLink {
  const ScreenplayCharacterLink({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory ScreenplayCharacterLink.fromJson(Map<String, dynamic> json) {
    return ScreenplayCharacterLink(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

void ensureDraftCharacterLinked(
  ScreenplayDraft draft, {
  required int id,
  required String name,
}) {
  if (id <= 0 || name.trim().isEmpty) return;
  if (draft.linkedCharacters.any((c) => c.id == id)) return;
  draft.linkedCharacters.add(ScreenplayCharacterLink(id: id, name: name.trim()));
}

List<ScreenplayCharacterLink> collectLinkedCharactersFromDraft(
  ScreenplayDraft draft,
) {
  final merged = <int, ScreenplayCharacterLink>{};
  for (final link in draft.linkedCharacters) {
    if (link.id > 0) merged[link.id] = link;
  }
  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      for (final frame in scene.frames) {
        final id = frame.characterId;
        final name = frame.characterName.trim();
        if (id != null && id > 0 && name.isNotEmpty) {
          merged.putIfAbsent(
            id,
            () => ScreenplayCharacterLink(id: id, name: name),
          );
        }
      }
    }
  }
  return merged.values.toList(growable: false);
}

class ScreenplaySceneLink {
  const ScreenplaySceneLink({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory ScreenplaySceneLink.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is String
        ? rawId
        : rawId is num
            ? rawId.toString()
            : '';
    return ScreenplaySceneLink(
      id: id,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
    );
  }
}

void ensureDraftSceneLinked(
  ScreenplayDraft draft, {
  required String id,
  required String title,
}) {
  if (id.isEmpty || title.trim().isEmpty) return;
  if (draft.linkedScenes.any((s) => s.id == id)) return;
  draft.linkedScenes.add(
    ScreenplaySceneLink(id: id, title: title.trim()),
  );
}

List<ScreenplaySceneLink> collectLinkedScenesFromDraft(
  ScreenplayDraft draft,
) {
  final merged = <String, ScreenplaySceneLink>{};
  for (final link in draft.linkedScenes) {
    if (link.id.isNotEmpty) merged[link.id] = link;
  }
  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      final id = scene.sceneLibraryId;
      final title = scene.sceneLibraryTitle.trim();
      if (id != null && id.isNotEmpty && title.isNotEmpty) {
        merged.putIfAbsent(
          id,
          () => ScreenplaySceneLink(id: id, title: title),
        );
      }
    }
  }
  return merged.values.toList(growable: false);
}

class ScreenplayDraft {
  ScreenplayDraft({
    this.title = '',
    this.synopsis = '',
    Set<String>? tags,
    List<ActDraft>? acts,
    this.coverImage,
    ShootParams? defaultParams,
    List<ScreenplayCharacterLink>? linkedCharacters,
    List<ScreenplaySceneLink>? linkedScenes,
    this.lightingSchemeId,
    this.lightingRig,
    this.cineSetupId,
    this.cineSetup,
  })  : tags = Set<String>.from(tags ?? {'站姿'}),
        acts = acts ?? [ActDraft()],
        defaultParams = defaultParams ?? AppCatalog.defaultShootParams,
        linkedCharacters = linkedCharacters ?? [],
        linkedScenes = linkedScenes ?? [];

  factory ScreenplayDraft.fromScreenplay(Screenplay screenplay) {
    final acts = <ActDraft>[];
    for (final act in screenplay.acts) {
      final scenes = <SceneDraft>[];
      for (final scene in act.scenes) {
        final frames = scene.frames
            .map(
              (frame) => FrameDraft(
                image: UploadImageFile(
                  path: frame.localImagePath ?? frame.imagePath,
                  name: _basename(frame.localImagePath ?? frame.imagePath),
                  previewPath: frame.localThumbnailPath,
                ),
                caption: frame.caption,
                actionNote: frame.actionNote,
                tags: Set<String>.from(frame.tags),
              ),
            )
            .toList();
        scenes.add(
          SceneDraft(
            title: scene.title,
            location: scene.location,
            timeOfDay: scene.timeOfDay,
            description: scene.description,
            frames: frames,
          ),
        );
      }
      acts.add(
        ActDraft(
          title: act.title,
          synopsis: act.synopsis,
          scenes: scenes.isEmpty ? [SceneDraft()] : scenes,
        ),
      );
    }

    UploadImageFile? coverImage;
    final explicitLocal = screenplay.localCoverPath;
    final explicitRemote = screenplay.coverUrl;
    if (explicitLocal != null &&
        explicitLocal.isNotEmpty &&
        !_isNetworkUrl(explicitLocal)) {
      coverImage = UploadImageFile(
        path: explicitLocal,
        name: _basename(explicitLocal),
      );
    } else if (explicitRemote != null &&
        explicitRemote.isNotEmpty &&
        _isNetworkUrl(explicitRemote)) {
      coverImage = UploadImageFile(
        path: explicitRemote,
        name: _basename(explicitRemote),
      );
    }

    if (coverImage != null) {
      final defaultPath = _defaultCoverPathFromActs(acts);
      if (defaultPath != null && coverImage.path == defaultPath) {
        coverImage = null;
      }
    }

    return ScreenplayDraft(
      title: screenplay.title,
      synopsis: screenplay.synopsis,
      tags: screenplay.tags.isNotEmpty
          ? Set<String>.from(screenplay.tags)
          : {'站姿'},
      acts: acts.isEmpty ? [ActDraft()] : acts,
      coverImage: coverImage,
    );
  }

  String title;
  String synopsis;
  Set<String> tags;
  final List<ActDraft> acts;
  ShootParams defaultParams;
  final List<ScreenplayCharacterLink> linkedCharacters;
  final List<ScreenplaySceneLink> linkedScenes;
  String? lightingSchemeId;
  Map<String, dynamic>? lightingRig;
  String? cineSetupId;
  Map<String, dynamic>? cineSetup;

  /// Explicit cover; null means use the first frame/image as default.
  UploadImageFile? coverImage;

  bool get hasFrames =>
      acts.any((act) => act.scenes.any((scene) => scene.frames.isNotEmpty));

  bool get usesDefaultCover => coverImage == null;

  ScreenplayDraft copyDeep() {
    return ScreenplayDraft(
      title: title,
      synopsis: synopsis,
      tags: Set<String>.from(tags),
      acts: acts.map((a) => a.copyDeep()).toList(),
      coverImage: coverImage == null
          ? null
          : UploadImageFile(
              path: coverImage!.path,
              name: coverImage!.name,
              previewPath: coverImage!.previewPath,
            ),
      defaultParams: defaultParams.copyWith(),
      lightingSchemeId: lightingSchemeId,
      lightingRig: lightingRig != null
          ? Map<String, dynamic>.from(lightingRig!)
          : null,
      cineSetupId: cineSetupId,
      cineSetup:
          cineSetup != null ? Map<String, dynamic>.from(cineSetup!) : null,
      linkedCharacters: linkedCharacters
          .map((c) => ScreenplayCharacterLink(id: c.id, name: c.name))
          .toList(),
      linkedScenes: linkedScenes
          .map((s) => ScreenplaySceneLink(id: s.id, title: s.title))
          .toList(),
    );
  }
}

bool _isNetworkUrl(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

String? _defaultCoverPathFromActs(List<ActDraft> acts) {
  for (final act in acts) {
    for (final scene in act.scenes) {
      for (final frame in scene.frames) {
        return frame.image.displayPath;
      }
    }
  }
  return null;
}

/// First frame media in draft order (act → scene → frame).
UploadImageFile? firstDraftFrameMedia(ScreenplayDraft draft) {
  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      if (scene.frames.isNotEmpty) {
        return scene.frames.first.image;
      }
    }
  }
  return null;
}

/// Cover path for UI preview: explicit cover, else first frame (video → thumbnail).
String? draftCoverDisplayPath(ScreenplayDraft draft) {
  if (draft.coverImage != null) {
    return draft.coverImage!.displayPath;
  }
  return firstDraftFrameMedia(draft)?.displayPath;
}

String _newId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}';

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final index = normalized.lastIndexOf('/');
  return index >= 0 ? normalized.substring(index + 1) : normalized;
}

Screenplay buildScreenplayFromDraft(
  ScreenplayDraft draft, {
  required Map<UploadImageFile, String> persistedPaths,
  String? scriptId,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? coverPath,
}) {
  final resolvedId = scriptId ?? _newId('script');
  final acts = <ScriptAct>[];

  for (var actIndex = 0; actIndex < draft.acts.length; actIndex++) {
    final actDraft = draft.acts[actIndex];
    final actId = '$resolvedId-act-$actIndex';
    final scenes = <ScriptScene>[];

    for (var sceneIndex = 0; sceneIndex < actDraft.scenes.length; sceneIndex++) {
      final sceneDraft = actDraft.scenes[sceneIndex];
      final sceneId = '$actId-scene-$sceneIndex';
      final frames = <ScriptFrame>[];

      for (var frameIndex = 0; frameIndex < sceneDraft.frames.length; frameIndex++) {
        final frameDraft = sceneDraft.frames[frameIndex];
        final path = persistedPaths[frameDraft.image];
        if (path == null || path.isEmpty) continue;

        String? thumbPath;
        if (frameDraft.image.isVideo) {
          thumbPath = persistedPaths[frameDraft.image.previewPathKey] ??
              frameDraft.image.previewPath;
        }

        frames.add(
          ScriptFrame(
            id: '$sceneId-frame-$frameIndex',
            orderIndex: frameIndex,
            imagePath: thumbPath ?? path,
            localImagePath: path,
            localThumbnailPath: thumbPath,
            caption: frameDraft.caption,
            actionNote: frameDraft.actionNote,
            tags: frameDraft.tags.toList(),
          ),
        );
      }

      scenes.add(
        ScriptScene(
          id: sceneId,
          orderIndex: sceneIndex,
          title: sceneDraft.title.trim().isEmpty
              ? '第${sceneIndex + 1}场'
              : sceneDraft.title.trim(),
          location: sceneDraft.location.trim(),
          timeOfDay: sceneDraft.timeOfDay.trim(),
          description: sceneDraft.description.trim(),
          frames: frames,
        ),
      );
    }

    acts.add(
      ScriptAct(
        id: actId,
        orderIndex: actIndex,
        title: actDraft.title.trim().isEmpty
            ? '第${actIndex + 1}幕'
            : actDraft.title.trim(),
        synopsis: actDraft.synopsis.trim(),
        scenes: scenes,
      ),
    );
  }

  return Screenplay(
    id: resolvedId,
    title: draft.title.trim().isEmpty ? '未命名剧本' : draft.title.trim(),
    synopsis: draft.synopsis.trim(),
    tags: draftTagPoolSorted(draft),
    author: '我',
    authorBio: '本地发布',
    likes: 0,
    views: 0,
    favorites: 0,
    acts: acts,
    isLocal: true,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
    localCoverPath: coverPath,
  );
}

List<UploadImageFile> collectDraftImages(ScreenplayDraft draft) {
  final images = <UploadImageFile>[];
  final seen = <String>{};

  void add(UploadImageFile file) {
    if (seen.add(file.path)) {
      images.add(file);
    }
    final preview = file.previewPath;
    if (preview != null &&
        preview.isNotEmpty &&
        seen.add(preview)) {
      images.add(UploadImageFile(path: preview, name: _basename(preview)));
    }
  }

  if (draft.coverImage != null) {
    add(draft.coverImage!);
  }

  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      for (final frame in scene.frames) {
        add(frame.image);
        for (final ref in frame.referenceImages) {
          add(ref);
        }
      }
    }
  }
  return images;
}

int countDraftFrames(ScreenplayDraft draft) {
  var count = 0;
  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      count += scene.frames.length;
    }
  }
  return count;
}

int countDraftScenes(ScreenplayDraft draft) {
  return draft.acts.fold(0, (sum, act) => sum + act.scenes.length);
}

String draftHierarchySummary(ScreenplayDraft draft) {
  return '${draft.acts.length}幕 · ${countDraftScenes(draft)}场 · ${countDraftFrames(draft)}画';
}

/// Reference to a frame within the draft hierarchy.
class DraftFrameRef {
  const DraftFrameRef({
    required this.actIndex,
    required this.sceneIndex,
    required this.frameIndex,
    required this.frame,
    required this.preview,
    required this.sceneTitle,
    required this.actTitle,
  });

  final int actIndex;
  final int sceneIndex;
  final int frameIndex;
  final FrameDraft frame;
  final ScriptFrame preview;
  final String sceneTitle;
  final String actTitle;

  String get shotLabel =>
      '${actIndex + 1}-${sceneIndex + 1}-${frameIndex + 1}';
}

ScriptFrame frameDraftToPreviewFrame({
  required FrameDraft frame,
  required String id,
  required int orderIndex,
}) {
  return ScriptFrame(
    id: id,
    orderIndex: orderIndex,
    imagePath: frame.image.displayPath,
    localImagePath: frame.image.path,
    localThumbnailPath: frame.image.previewPath,
    caption: frame.caption,
    actionNote: frame.actionNote,
    tags: frame.tags.toList(),
  );
}

List<ScriptFrame> draftFramesForScene(
  ScreenplayDraft draft,
  int actIndex,
  int sceneIndex,
) {
  if (actIndex < 0 || actIndex >= draft.acts.length) return const [];
  final scenes = draft.acts[actIndex].scenes;
  if (sceneIndex < 0 || sceneIndex >= scenes.length) return const [];

  final scene = scenes[sceneIndex];
  return [
    for (var i = 0; i < scene.frames.length; i++)
      frameDraftToPreviewFrame(
        frame: scene.frames[i],
        id: 'draft-$actIndex-$sceneIndex-$i',
        orderIndex: i,
      ),
  ];
}

List<DraftFrameRef> draftAllFrameRefs(
  ScreenplayDraft draft, {
  int? filterActIndex,
  int? filterSceneIndex,
}) {
  final refs = <DraftFrameRef>[];
  for (var actIndex = 0; actIndex < draft.acts.length; actIndex++) {
    if (filterActIndex != null && actIndex != filterActIndex) continue;
    final act = draft.acts[actIndex];
    final actTitle = act.title.trim().isEmpty
        ? '第${actIndex + 1}幕'
        : act.title.trim();
    for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
      if (filterSceneIndex != null && sceneIndex != filterSceneIndex) {
        continue;
      }
      final scene = act.scenes[sceneIndex];
      final sceneTitle = scene.title.trim().isEmpty
          ? '第${sceneIndex + 1}场'
          : scene.title.trim();
      for (var frameIndex = 0; frameIndex < scene.frames.length; frameIndex++) {
        final frame = scene.frames[frameIndex];
        refs.add(
          DraftFrameRef(
            actIndex: actIndex,
            sceneIndex: sceneIndex,
            frameIndex: frameIndex,
            frame: frame,
            preview: frameDraftToPreviewFrame(
              frame: frame,
              id: 'draft-$actIndex-$sceneIndex-$frameIndex',
              orderIndex: frameIndex,
            ),
            sceneTitle: sceneTitle,
            actTitle: actTitle,
          ),
        );
      }
    }
  }
  return refs;
}

/// Pick target for image picker within draft hierarchy.
class FramePickTarget {
  FramePickTarget({required this.actIndex, required this.sceneIndex});

  final int actIndex;
  final int sceneIndex;
}

void addImagesToScene(
  ScreenplayDraft draft,
  FramePickTarget target,
  List<UploadImageFile> images,
) {
  final scene = draft.acts[target.actIndex].scenes[target.sceneIndex];
  for (final image in images) {
    scene.frames.add(FrameDraft(image: image));
  }
}

/// Reorders [list] in place. [newIndex] must use [ReorderableListView.onReorderItem]
/// semantics (already adjusted for the removal at [oldIndex]).
void reorderDraftList<T>(List<T> list, int oldIndex, int newIndex) {
  if (oldIndex == newIndex) return;
  final item = list.removeAt(oldIndex);
  list.insert(newIndex, item);
}

void reorderDraftActs(ScreenplayDraft draft, int oldIndex, int newIndex) {
  reorderDraftList(draft.acts, oldIndex, newIndex);
}

void reorderDraftScenes(
  ScreenplayDraft draft,
  int actIndex,
  int oldIndex,
  int newIndex,
) {
  reorderDraftList(draft.acts[actIndex].scenes, oldIndex, newIndex);
}

void reorderDraftFrames(
  ScreenplayDraft draft,
  int actIndex,
  int sceneIndex,
  int oldIndex,
  int newIndex,
) {
  reorderDraftList(
    draft.acts[actIndex].scenes[sceneIndex].frames,
    oldIndex,
    newIndex,
  );
}

/// Drag payload for moving a [SceneDraft] across acts.
class SceneDragData {
  const SceneDragData({
    required this.fromActIndex,
    required this.scene,
  });

  final int fromActIndex;
  final SceneDraft scene;
}

/// Drag payload for moving a [FrameDraft] across scenes.
class FrameDragData {
  const FrameDragData({
    required this.fromActIndex,
    required this.fromScene,
    required this.frame,
  });

  final int fromActIndex;
  final SceneDraft fromScene;
  final FrameDraft frame;
}

void _ensureActHasScene(ActDraft act) {
  if (act.scenes.isEmpty) {
    act.scenes.add(SceneDraft());
  }
}

/// Inserts [scene] before [toInsertIndex] in the destination act's scene list.
/// [toInsertIndex] is relative to the list **before** the scene is removed.
void moveDraftScene(
  ScreenplayDraft draft, {
  required SceneDraft scene,
  required int fromActIndex,
  required int toActIndex,
  required int toInsertIndex,
}) {
  if (fromActIndex < 0 ||
      fromActIndex >= draft.acts.length ||
      toActIndex < 0 ||
      toActIndex >= draft.acts.length) {
    return;
  }

  final fromAct = draft.acts[fromActIndex];
  final fromSceneIndex = fromAct.scenes.indexOf(scene);
  if (fromSceneIndex < 0) return;

  var insertIndex = toInsertIndex;
  if (fromActIndex == toActIndex) {
    if (fromSceneIndex == insertIndex) return;
    if (fromSceneIndex < insertIndex) {
      insertIndex--;
    }
  }

  fromAct.scenes.removeAt(fromSceneIndex);
  _ensureActHasScene(fromAct);

  final toAct = draft.acts[toActIndex];
  insertIndex = insertIndex.clamp(0, toAct.scenes.length);
  toAct.scenes.insert(insertIndex, scene);
}

/// Inserts [frame] before [toInsertIndex] in the destination scene's frame list.
void moveDraftFrame(
  ScreenplayDraft draft, {
  required FrameDraft frame,
  required int fromActIndex,
  required SceneDraft fromScene,
  required int toActIndex,
  required SceneDraft toScene,
  required int toInsertIndex,
}) {
  if (fromActIndex < 0 ||
      fromActIndex >= draft.acts.length ||
      toActIndex < 0 ||
      toActIndex >= draft.acts.length) {
    return;
  }

  final fromAct = draft.acts[fromActIndex];
  final fromSceneIndex = fromAct.scenes.indexOf(fromScene);
  if (fromSceneIndex < 0) return;

  final fromFrames = fromAct.scenes[fromSceneIndex].frames;
  final fromFrameIndex = fromFrames.indexOf(frame);
  if (fromFrameIndex < 0) return;

  final toAct = draft.acts[toActIndex];
  final toSceneIndex = toAct.scenes.indexOf(toScene);
  if (toSceneIndex < 0) return;

  var insertIndex = toInsertIndex;
  final sameScene =
      fromActIndex == toActIndex && fromSceneIndex == toSceneIndex;
  if (sameScene) {
    if (fromFrameIndex == insertIndex) return;
    if (fromFrameIndex < insertIndex) {
      insertIndex--;
    }
  }

  fromFrames.removeAt(fromFrameIndex);

  final toFrames = toAct.scenes[toSceneIndex].frames;
  insertIndex = insertIndex.clamp(0, toFrames.length);
  toFrames.insert(insertIndex, frame);
}

extension UploadImageFilePersistKey on UploadImageFile {
  UploadImageFile get previewPathKey => UploadImageFile(
        path: previewPath ?? path,
        name: previewPath != null ? _basename(previewPath!) : name,
      );
}
