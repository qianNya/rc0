import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../data/screenplay_local_repository.dart';
import '../../data/screenplay_remote_repository.dart';

class ScriptShotDetailPage extends StatefulWidget {
  const ScriptShotDetailPage({
    super.key,
    required this.scriptId,
    required this.sceneId,
    required this.shotId,
  });

  final String scriptId;
  final String sceneId;
  final String shotId;

  @override
  State<ScriptShotDetailPage> createState() => _ScriptShotDetailPageState();
}

class _ScriptShotDetailPageState extends State<ScriptShotDetailPage> {
  bool _loading = true;
  String? _error;
  ScriptFrame? _frame;
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
    ScriptFrame? frame;
    if (screenplay != null) {
      for (final act in screenplay.acts) {
        for (final s in act.scenes) {
          if (s.id == widget.sceneId) {
            scene = s;
            for (final f in s.frames) {
              if (f.id == widget.shotId) {
                frame = f;
                break;
              }
            }
            break;
          }
        }
        if (frame != null) break;
      }
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _scene = scene;
      _frame = frame;
      if (frame == null && _error == null) _error = '未找到分镜';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _frame == null) {
      return DesktopStackScaffold(
        title: const Text('分镜详情'),
        onBack: () => context.pop(),
        body: InlineErrorBanner(message: _error ?? '加载失败', onRetry: _load),
      );
    }

    final frame = _frame!;
    return GlassHeroPage(
      onBack: () => context.pop(),
      hero: Rc0Image(path: frame.displayImagePath, fit: BoxFit.contain),
      heroHeight: 420,
      infoCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            frame.caption.isEmpty
                ? '分镜 ${frame.orderIndex + 1}'
                : frame.caption,
            style: AppTextStyles.title,
          ),
          if (_scene != null)
            Text(_scene!.title, style: AppTextStyles.bodySecondary),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (frame.actionNote.isNotEmpty)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('动作备注', style: AppTextStyles.label),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(frame.actionNote, style: AppTextStyles.body),
                  ],
                ),
              ),
            if (frame.tags.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Wrap(
                spacing: AppDimensions.spacingSm,
                children: frame.tags
                    .map((t) => GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingMd,
                            vertical: AppDimensions.spacingSm,
                          ),
                          child: Text(t, style: AppTextStyles.caption),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
