import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/rc0_image.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../domain/scene_entry.dart';

class SceneInspirationTab extends StatelessWidget {
  const SceneInspirationTab({
    super.key,
    required this.entry,
    this.localCover,
    this.referenceUrls = const [],
  });

  final SceneEntry entry;
  final String? localCover;
  final List<String> referenceUrls;

  @override
  Widget build(BuildContext context) {
    final urls = <String>[
      if (localCover != null && localCover!.isNotEmpty) localCover!,
      if (entry.coverUrl.isNotEmpty) entry.coverUrl,
      ...referenceUrls,
      ...entry.imageUrls,
    ];

    if (urls.isEmpty) {
      return Center(
        child: Text('暂无参考图', style: AppTextStyles.bodySecondary),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final path = urls[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: path.isNotEmpty
              ? Rc0Image(path: path, fit: BoxFit.cover)
              : const PlaceholderImage(aspectRatio: 3 / 4, borderRadius: 12),
        );
      },
    );
  }
}
