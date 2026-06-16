import '../../../../core/domain/screenplay/script_frame.dart';
import 'screenplay_image_resolver.dart';

extension ScriptFrameDisplay on ScriptFrame {
  String get effectiveDisplayPath =>
      ScreenplayImageResolver.effectiveDisplayPath(
        localPath: localImagePath,
        remoteUrl: remoteImageUrl,
        legacyPath: imagePath,
      ) ??
      '';
}
