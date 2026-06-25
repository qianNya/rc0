import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/shell_bar_icon_button.dart';

class GalleryPageHeader extends StatelessWidget {
  const GalleryPageHeader({
    super.key,
    this.onUpload,
    this.uploading = false,
  });

  final VoidCallback? onUpload;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.shellBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('图库', style: AppTextStyles.title),
            Row(
              children: [
                const Spacer(),
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
          ],
        ),
      ),
    );
  }
}
