import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/data/screenplay_draft_tags.dart';

enum DraftMetaChipKind { tag, scene, character }

enum DraftMetaChipLayout { wrap, singleLine }

class DraftMetaChipData {
  const DraftMetaChipData({required this.label, required this.kind});

  final String label;
  final DraftMetaChipKind kind;
}

List<DraftMetaChipData> collectDraftMetaChips(
  ScreenplayDraft draft, {
  int? maxTags,
}) {
  final items = <DraftMetaChipData>[];

  final tags = draftTagPoolSorted(draft);
  final tagLimit = maxTags ?? tags.length;
  for (final tag in tags.take(tagLimit)) {
    items.add(DraftMetaChipData(label: tag, kind: DraftMetaChipKind.tag));
  }

  for (final scene in collectLinkedScenesFromDraft(draft)) {
    final title = scene.title.trim();
    if (title.isEmpty) continue;
    items.add(DraftMetaChipData(label: title, kind: DraftMetaChipKind.scene));
  }

  for (final character in collectLinkedCharactersFromDraft(draft)) {
    final name = character.name.trim();
    if (name.isEmpty) continue;
    items.add(
      DraftMetaChipData(label: name, kind: DraftMetaChipKind.character),
    );
  }

  return items;
}

class DraftMetaChipRow extends StatelessWidget {
  const DraftMetaChipRow({
    super.key,
    required this.draft,
    this.leading,
    this.maxTags,
    this.spacing = 4,
    this.runSpacing = 4,
    this.fontSize = 10,
    this.layout = DraftMetaChipLayout.wrap,
  });

  final ScreenplayDraft draft;
  final Widget? leading;
  final int? maxTags;
  final double spacing;
  final double runSpacing;
  final double fontSize;
  final DraftMetaChipLayout layout;

  @override
  Widget build(BuildContext context) {
    final items = collectDraftMetaChips(draft, maxTags: maxTags);
    if (layout == DraftMetaChipLayout.singleLine) {
      if (items.isEmpty) return const SizedBox.shrink();
      return _SingleLineMetaChips(
        items: items,
        spacing: spacing,
        fontSize: fontSize,
      );
    }

    if (leading == null && items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ?leading,
        for (final item in items)
          _MetaChip(label: item.label, kind: item.kind, fontSize: fontSize),
      ],
    );
  }
}

class _SingleLineMetaChips extends StatelessWidget {
  const _SingleLineMetaChips({
    required this.items,
    required this.spacing,
    required this.fontSize,
  });

  final List<DraftMetaChipData> items;
  final double spacing;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth <= 0 || items.isEmpty) {
          return const SizedBox.shrink();
        }

        final visible = <DraftMetaChipData>[];
        var used = 0.0;
        final moreWidth = _MoreIndicator.widthFor(fontSize);

        for (var i = 0; i < items.length; i++) {
          final chipWidth = _MetaChip.measureWidth(items[i], fontSize);
          final hiddenAfter = items.length - visible.length - 1;
          final reserve = hiddenAfter > 0 ? moreWidth + spacing : 0.0;

          if (visible.isNotEmpty && used + chipWidth + reserve > maxWidth) {
            break;
          }
          if (visible.isEmpty && chipWidth > maxWidth) {
            visible.add(items[i]);
            break;
          }
          if (used + chipWidth + reserve > maxWidth) {
            break;
          }

          visible.add(items[i]);
          used += chipWidth + spacing;
        }

        final hasOverflow = visible.length < items.length;

        return Row(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              _MetaChip(
                label: visible[i].label,
                kind: visible[i].kind,
                fontSize: fontSize,
              ),
            ],
            if (hasOverflow) ...[
              SizedBox(width: spacing),
              _MoreIndicator(fontSize: fontSize),
            ],
          ],
        );
      },
    );
  }
}

class _MoreIndicator extends StatelessWidget {
  const _MoreIndicator({required this.fontSize});

  final double fontSize;

  static double widthFor(double fontSize) => fontSize * 2 + 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthFor(fontSize),
      child: Text(
        '...',
        maxLines: 1,
        style: AppTextStyles.bodySecondary.copyWith(
          fontSize: fontSize + 1,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.kind,
    required this.fontSize,
  });

  final String label;
  final DraftMetaChipKind kind;
  final double fontSize;

  static const _hPad = 6.0;
  static const _iconGap = 3.0;

  static double measureWidth(DraftMetaChipData data, double fontSize) {
    final icon = _iconFor(data.kind);
    final tp = TextPainter(
      text: TextSpan(
        text: data.label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: fontSize),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final iconWidth = icon == null ? 0.0 : fontSize + 2 + _iconGap;
    return _hPad * 2 + iconWidth + tp.width;
  }

  static IconData? _iconFor(DraftMetaChipKind kind) => switch (kind) {
        DraftMetaChipKind.tag => null,
        DraftMetaChipKind.scene => Icons.landscape_outlined,
        DraftMetaChipKind.character => Icons.person_outline,
      };

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData? icon) = switch (kind) {
      DraftMetaChipKind.tag => (
          AppColors.accentLight,
          AppColors.accent,
          null,
        ),
      DraftMetaChipKind.scene => (
          AppColors.surfaceSecondary,
          AppColors.badgeTemplate,
          Icons.landscape_outlined,
        ),
      DraftMetaChipKind.character => (
          AppColors.sidebarActive,
          AppColors.profileGradientEnd,
          Icons.person_outline,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _hPad,
        vertical: fontSize <= 9 ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: kind == DraftMetaChipKind.tag
            ? null
            : Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: _iconGap),
          ],
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: fontSize,
              color: fg,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
