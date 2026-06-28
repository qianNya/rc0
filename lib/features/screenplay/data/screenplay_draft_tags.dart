import 'screenplay_draft.dart';

Set<String> parseDraftTagList(dynamic raw) {
  if (raw is! List) return {};
  return raw
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toSet();
}

/// Union of screenplay + act + scene + frame tag sets.
Set<String> draftTagPool(ScreenplayDraft draft) {
  final pool = <String>{...draft.tags};
  for (final act in draft.acts) {
    pool.addAll(act.tags);
    for (final scene in act.scenes) {
      pool.addAll(scene.tags);
      for (final frame in scene.frames) {
        pool.addAll(frame.tags);
      }
    }
  }
  return pool;
}

List<String> draftTagPoolSorted(ScreenplayDraft draft) {
  final list = draftTagPool(draft).toList()..sort();
  return list;
}

void toggleDraftNodeTag(Set<String> nodeTags, String tag) {
  if (nodeTags.contains(tag)) {
    nodeTags.remove(tag);
  } else {
    nodeTags.add(tag);
  }
}

void addTagToDraftPool(ScreenplayDraft draft, String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return;
  draft.tags.add(trimmed);
}

List<String> mergeTagSuggestions({
  required Set<String> pool,
  required List<String> remoteSuggestions,
}) {
  return {...pool, ...remoteSuggestions}.toList()..sort();
}

/// Whether [ref] carries [tag] on the frame or any ancestor node in the draft.
bool draftFrameMatchesTag(
  ScreenplayDraft draft,
  DraftFrameRef ref,
  String tag,
) {
  if (tag.isEmpty) return true;
  if (draft.tags.contains(tag)) return true;
  if (ref.actIndex < 0 || ref.actIndex >= draft.acts.length) return false;
  final act = draft.acts[ref.actIndex];
  if (act.tags.contains(tag)) return true;
  if (ref.sceneIndex < 0 || ref.sceneIndex >= act.scenes.length) return false;
  final scene = act.scenes[ref.sceneIndex];
  if (scene.tags.contains(tag)) return true;
  return ref.frame.tags.contains(tag);
}

/// Whether [ref] matches any tag in [tags] (OR semantics).
bool draftFrameMatchesAnyTag(
  ScreenplayDraft draft,
  DraftFrameRef ref,
  Set<String> tags,
) {
  if (tags.isEmpty) return true;
  for (final tag in tags) {
    if (draftFrameMatchesTag(draft, ref, tag)) return true;
  }
  return false;
}
