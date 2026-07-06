import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/media_vault_image.dart';
import 'media_vault_colors.dart';

class MediaVaultTagsPanel extends StatelessWidget {
  const MediaVaultTagsPanel({
    super.key,
    required this.tags,
    required this.onTagTap,
  });

  final List<MediaTagEntry> tags;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    final manual = tags.where((t) => !t.isAi).toList(growable: false);
    final ai = tags.where((t) => t.isAi).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        _Section(
          title: '全部标签',
          tags: manual,
          onTagTap: onTagTap,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _Section(
          title: 'AI 标签',
          tags: ai,
          onTagTap: onTagTap,
          ai: true,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        const Text(
          '热门标签',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: MediaVaultColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .take(6)
              .map(
                (t) => ActionChip(
                  label: Text('${t.name} (${t.count})'),
                  backgroundColor: MediaVaultColors.surfaceElevated,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    color: MediaVaultColors.highlightBlue,
                  ),
                  side: const BorderSide(color: MediaVaultColors.border),
                  onPressed: () => onTagTap(t.name),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.tags,
    required this.onTagTap,
    this.ai = false,
  });

  final String title;
  final List<MediaTagEntry> tags;
  final ValueChanged<String> onTagTap;
  final bool ai;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MediaVaultColors.textTertiary,
              ),
            ),
            if (ai) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MediaVaultColors.accentGlow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: MediaVaultColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        ...tags.map(
          (t) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.name,
              style: const TextStyle(
                fontSize: 14,
                color: MediaVaultColors.textPrimary,
              ),
            ),
            trailing: Text(
              '${t.count}',
              style: const TextStyle(
                fontSize: 12,
                color: MediaVaultColors.textTertiary,
              ),
            ),
            onTap: () => onTagTap(t.name),
          ),
        ),
      ],
    );
  }
}
