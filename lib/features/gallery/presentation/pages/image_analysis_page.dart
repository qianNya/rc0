import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../api/image/api/image-api.dart' as image_api;
import '../../../../api/image/data/image-api.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/network/api_callback.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';

class ImageAnalysisPage extends StatefulWidget {
  const ImageAnalysisPage({super.key, required this.imageId});

  final int imageId;

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  bool _loading = true;
  bool _retrying = false;
  String? _error;
  ImageAnalysisResp? _analysis;

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
    final (data, err) = await apiCallback<ImageAnalysisResp>(
      ({ok, fail, eventually}) => image_api.getImageAnalysis(
        widget.imageId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _analysis = data;
      _error = err;
    });
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => image_api.retryImageAnalysis(
        widget.imageId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (!mounted) return;
    setState(() => _retrying = false);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('AI 视觉分析'),
      onBack: () => context.pop(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return InlineErrorBanner(message: _error!, onRetry: _load);
    }
    final analysis = _analysis;
    if (analysis == null || analysis.summary.isEmpty) {
      return Center(
        child: GlassEmptyState(
          icon: Icons.auto_awesome_outlined,
          title: '暂无分析结果',
          subtitle: '可尝试重新分析',
          actionLabel: _retrying ? null : '重新分析',
          onAction: _retrying ? null : _retry,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('状态：${analysis.status}', style: AppTextStyles.caption),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(analysis.summary, style: AppTextStyles.body),
            ],
          ),
        ),
        if (analysis.labels.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Text('标签', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: analysis.labels
                .map((l) => GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                        vertical: AppDimensions.spacingSm,
                      ),
                      child: Text(l, style: AppTextStyles.caption),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
