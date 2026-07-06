import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/media_vault_types.dart';
import 'media_vault_colors.dart';

class MediaVaultSidebar extends StatelessWidget {
  const MediaVaultSidebar({
    super.key,
    required this.section,
    required this.onSectionChanged,
    required this.storageFraction,
    required this.storageLabel,
    this.quickTags = const [],
    this.onTagTap,
    this.width = 220,
  });

  final MediaVaultSection section;
  final ValueChanged<MediaVaultSection> onSectionChanged;
  final double storageFraction;
  final String storageLabel;
  final List<String> quickTags;
  final ValueChanged<String>? onTagTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MediaVaultColors.surface,
          border: Border(right: BorderSide(color: MediaVaultColors.border)),
        ),
        child: SafeArea(
          right: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
              AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Media Vault',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: MediaVaultColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                for (final s in MediaVaultSection.values)
                  _NavItem(
                    section: s,
                    selected: section == s,
                    onTap: () => onSectionChanged(s),
                  ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  storageLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: MediaVaultColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: storageFraction.clamp(0, 1),
                    minHeight: 4,
                    backgroundColor: MediaVaultColors.border,
                    color: MediaVaultColors.accent,
                  ),
                ),
                if (quickTags.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  const Text(
                    '快捷标签',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MediaVaultColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickTags
                        .take(8)
                        .map(
                          (tag) => GestureDetector(
                            onTap: onTagTap == null
                                ? null
                                : () => onTagTap!(tag),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: MediaVaultColors.highlightBlue,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: MediaVaultColors.accentGlow,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: MediaVaultColors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NyaQian',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MediaVaultColors.textPrimary,
                            ),
                          ),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              color: MediaVaultColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final MediaVaultSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? MediaVaultColors.sidebarActive
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected ? section.selectedIcon : section.icon,
                  size: 18,
                  color: selected
                      ? MediaVaultColors.accent
                      : MediaVaultColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  section.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? MediaVaultColors.textPrimary
                        : MediaVaultColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
