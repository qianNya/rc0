import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/platform/platform_features.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../features/shell/presentation/widgets/desktop_title_bar.dart';
import '../../../../shared/widgets/desktop/desktop_card.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
import '../../../../shared/widgets/shell_bar_icon_button.dart';

class GalleryPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const GalleryPageHeader({
    super.key,
    this.onUpload,
    this.uploading = false,
  });

  final VoidCallback? onUpload;
  final bool uploading;

  @override
  Size get preferredSize => const Size.fromHeight(kDesktopTitleBarHeight);

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesktopChrome.gap),
      child: Row(
        children: [
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
          if (Breakpoints.isDesktop(context) && shouldUseDesktopWindowChrome)
            const SizedBox(width: DesktopChrome.gap),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopChrome =
        Breakpoints.isDesktop(context) && shouldUseDesktopWindowChrome;

    if (isDesktopChrome) {
      return DesktopCard(
        clipChild: true,
        child: DesktopMergedTitleBar(
          decoration: const BoxDecoration(color: AppColors.surface),
          child: _buildContent(context),
        ),
      );
    }

    return SizedBox(
      height: AppDimensions.shellBarHeight,
      child: _buildContent(context),
    );
  }
}
