import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';

/// Gallery top bar — wiki floating chrome.
class GalleryPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const GalleryPageHeader({
    super.key,
    this.onUpload,
    this.uploading = false,
  });

  final VoidCallback? onUpload;
  final bool uploading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return WikiModeTagAppBar(
      title: '图库',
      actions: [
        if (uploading)
          const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (onUpload != null)
          WikiModeTagIconButton(
            icon: Icons.add_photo_alternate_outlined,
            tooltip: '上传图片',
            onPressed: onUpload,
          ),
        WikiModeTagIconButton(
          icon: Icons.search,
          tooltip: '搜索',
          onPressed: () => context.push(AppRoutes.search),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
