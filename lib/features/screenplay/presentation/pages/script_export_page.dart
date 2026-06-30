import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../data/screenplay_bundle_service.dart';
import '../../data/screenplay_local_repository.dart';
import '../../data/screenplay_remote_repository.dart';
import '../../data/screenplay_tree_document.dart';

class ScriptExportPage extends StatefulWidget {
  const ScriptExportPage({super.key, required this.scriptId});

  final String scriptId;

  @override
  State<ScriptExportPage> createState() => _ScriptExportPageState();
}

class _ScriptExportPageState extends State<ScriptExportPage> {
  bool _exporting = false;
  String? _message;

  Future<ScreenplayTreeDocument?> _loadDocument() async {
    final remoteId = int.tryParse(widget.scriptId);
    if (remoteId != null) {
      final result = await ScreenplayRemoteRepository.instance
          .fetchScreenplayTree(remoteId);
      if (result.screenplay != null) {
        return ScreenplayTreeDocument.fromScreenplay(result.screenplay!);
      }
    }
    final local =
        ScreenplayLocalRepository.instance.findById(widget.scriptId);
    if (local != null) {
      return ScreenplayTreeDocument.fromScreenplay(local);
    }
    return null;
  }

  Future<void> _exportJson() async {
    setState(() {
      _exporting = true;
      _message = null;
    });

    final doc = await _loadDocument();
    if (doc == null) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _message = '无法加载剧本数据';
      });
      return;
    }

    final result = await ScreenplayBundleService.instance.exportToFile(doc);
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _message = result.error ??
          (result.path != null ? '已导出至 ${result.path}' : '已取消导出');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('导出分镜'),
      onBack: () => context.pop(),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('导出分镜', style: AppTextStyles.title),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    '将剧本结构导出为 .rc0.json 文件，可在其他设备导入。',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            GlassButton(
              label: _exporting ? '导出中…' : '导出 JSON',
              filled: true,
              loading: _exporting,
              onPressed: _exporting ? null : _exportJson,
            ),
            if (_message != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Text(_message!, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
