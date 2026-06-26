import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/platform/platform_features.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../shell/presentation/widgets/desktop_title_bar.dart';
import '../../../../shared/widgets/shell_bar_icon_button.dart';

class GalleryPageHeader extends StatelessWidget {
  const GalleryPageHeader({
    super.key,
    this.onUpload,
    this.uploading = false,
  });

  final VoidCallback? onUpload;
  final bool uploading;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  Widget _buildContent(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (isDesktop)
            ShellBarIconButton(
              icon: Icons.arrow_back,
              tooltip: '返回',
              onPressed: () => popOrGoDiscovery(context),
            ),
          if (shouldUseDesktopWindowChrome && _isMacOS)
            const DesktopWindowControls(),
          Expanded(
            child: Center(
              child: Text('图库', style: AppTextStyles.title),
            ),
          ),
          if (uploading)
            const SizedBox(
              width: AppDimensions.shellBarHeight,
              height: AppDimensions.shellBarHeight,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (onUpload != null)
            ShellBarIconButton(
              icon: Icons.add_photo_alternate_outlined,
              tooltip: '上传图片',
              onPressed: onUpload,
            ),
          ShellBarIconButton(
            icon: Icons.search,
            tooltip: '搜索',
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shouldUseDesktopWindowChrome) {
      return DesktopMergedTitleBar(child: _buildContent(context));
    }

    return SizedBox(
      height: AppDimensions.shellBarHeight,
      child: _buildContent(context),
    );
  }
}
