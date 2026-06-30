import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../api/image/api/image-api.dart' as image_api;
import '../../../../api/image/data/image-api.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/network/api_callback.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/rc0_image.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({super.key, required this.imageId});

  final int imageId;

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  bool _loading = true;
  String? _error;
  ImageDetailResp? _detail;

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
    final (detail, err) = await apiCallback<ImageDetailResp>(
      ({ok, fail, eventually}) => image_api.getImageDetail(
        widget.imageId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _detail = detail;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _detail == null) {
      return DesktopStackScaffold(
        title: const Text('图片'),
        onBack: () => context.pop(),
        body: InlineErrorBanner(message: _error ?? '加载失败', onRetry: _load),
      );
    }

    final detail = _detail!;
    return GlassHeroPage(
      onBack: () => context.pop(),
      hero: Rc0Image(
        path: detail.imageUrl.isNotEmpty ? detail.imageUrl : detail.thumbnailUrl,
        fit: BoxFit.cover,
      ),
      infoCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title.isEmpty ? '未命名图片' : detail.title,
            style: AppTextStyles.title,
          ),
          if (detail.description.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(detail.description, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (detail.tags.isNotEmpty)
              Wrap(
                spacing: AppDimensions.spacingSm,
                runSpacing: AppDimensions.spacingSm,
                children: detail.tags
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
            const SizedBox(height: AppDimensions.spacingLg),
            GlassButton(
              label: 'AI 视觉分析',
              filled: true,
              onPressed: () =>
                  context.push(AppRoutes.imageAnalysisPath('${widget.imageId}')),
            ),
          ],
        ),
      ),
    );
  }
}
