import '../../../../core/domain/screenplay/screenplay.dart';
import '../../upload/domain/upload_image_file.dart';
import 'screenplay_draft.dart';

/// Lightweight [Screenplay] for upload / draft preview UI (no persistence).
Screenplay previewScreenplayFromDraft(
  ScreenplayDraft draft, {
  String? id,
}) {
  final paths = <UploadImageFile, String>{};
  for (final image in collectDraftImages(draft)) {
    paths[image] = image.displayPath;
  }
  return buildScreenplayFromDraft(
    draft,
    persistedPaths: paths,
    scriptId: id ?? 'draft-preview',
    coverPath: draftCoverDisplayPath(draft),
  );
}
