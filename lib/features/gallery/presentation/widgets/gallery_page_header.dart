import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('图库', style: AppTextStyles.title),
          Row(
            children: [
              const Spacer(),
              if (uploading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (onUpload != null)
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  tooltip: '上传图片',
                  onPressed: onUpload,
                ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '搜索',
                onPressed: () => context.push(AppRoutes.search),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
