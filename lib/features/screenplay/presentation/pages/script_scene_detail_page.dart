import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../data/screenplay_local_repository.dart';
import '../../data/screenplay_remote_repository.dart';

class ScriptSceneDetailPage extends StatefulWidget {
  const ScriptSceneDetailPage({
    super.key,
    required this.scriptId,
    required this.sceneId,
  });

  final String scriptId;
  final String sceneId;

  @override
  State<ScriptSceneDetailPage> createState() => _ScriptSceneDetailPageState();
}

class _ScriptSceneDetailPageState extends State<ScriptSceneDetailPage> {
  bool _loading = true;
  String? _error;
  ScriptScene? _scene;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    Screenplay? screenplay;
    final remoteId = int.tryParse(widget.scriptId);
    if (remoteId != null) {
      final result =
          await ScreenplayRemoteRepository.instance.fetchScreenplayTree(
        remoteId,
      );
      screenplay = result.screenplay;
      _error = result.error;
    } else {
      screenplay = ScreenplayLocalRepository.instance.findById(widget.scriptId);
    }

    ScriptScene? scene;
    if (screenplay != null) {
      for (final act in screenplay.acts) {
        for (final s in act.scenes) {
          if (s.id == widget.sceneId) {
            scene = s;
            break;
          }
        }
        if (scene != null) break;
      }
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _scene = scene;
      if (scene == null && _error == null) _error = '未找到场景';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _scene == null) {
      return DesktopStackScaffold(
        title: const Text('场景详情'),
        onBack: () => context.pop(),
        body: InlineErrorBanner(message: _error ?? '加载失败', onRetry: _load),
      );
    }

    final scene = _scene!;
    final heroFrame = scene.frames.isNotEmpty ? scene.frames.first : null;

    return GlassHeroPage(
      onBack: () => context.pop(),
      hero: heroFrame != null
          ? Rc0Image(path: heroFrame.displayImagePath, fit: BoxFit.cover)
          : const ColoredBox(color: Colors.black12),
      infoCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scene.title, style: AppTextStyles.title),
          if (scene.location.isNotEmpty || scene.timeOfDay.isNotEmpty)
            Text(
              [scene.location, scene.timeOfDay].where((e) => e.isNotEmpty).join(' · '),
              style: AppTextStyles.bodySecondary,
            ),
          if (scene.description.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(scene.description, style: AppTextStyles.body),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('分镜 (${scene.frameCount})', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spacingSm),
            ...scene.frames.map((frame) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                child: GlassCard(
                  onTap: () => context.push(
                    AppRoutes.scriptShot(
                      widget.scriptId,
                      widget.sceneId,
                      frame.id,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                          child: Rc0Image(
                            path: frame.displayImagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(
                        child: Text(
                          frame.caption.isEmpty
                              ? '分镜 ${frame.orderIndex + 1}'
                              : frame.caption,
                          style: AppTextStyles.label,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
