import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/shell_nav_config_store.dart';
import '../../../../shared/widgets/glass/glass.dart';

/// Opens the bottom-nav customization sheet (multi-select, 1–5 tabs).
Future<void> showShellNavConfigSheet(BuildContext context) {
  return showGlassSheet<void>(
    context,
    padding: EdgeInsets.zero,
    child: const _ShellNavConfigSheet(),
  );
}

class _ShellNavConfigSheet extends StatefulWidget {
  const _ShellNavConfigSheet();

  @override
  State<_ShellNavConfigSheet> createState() => _ShellNavConfigSheetState();
}

class _ShellNavConfigSheetState extends State<_ShellNavConfigSheet> {
  final _store = ShellNavConfigStore.instance;
  late List<String> _draftIds;

  @override
  void initState() {
    super.initState();
    _draftIds = List<String>.from(_store.activeOptionIds);
  }

  bool get _canRemove => _draftIds.length > ShellNavConfigStore.minTabs;
  bool get _canAddMore => _draftIds.length < ShellNavConfigStore.maxTabs;

  void _toggle(String optionId) {
    setState(() {
      if (_draftIds.contains(optionId)) {
        if (!_canRemove) {
          HapticFeedback.lightImpact();
          return;
        }
        _draftIds.remove(optionId);
      } else {
        if (!_canAddMore) {
          HapticFeedback.lightImpact();
          return;
        }
        _draftIds.add(optionId);
      }
    });
  }

  void _removeAt(int index) {
    if (!_canRemove) {
      HapticFeedback.lightImpact();
      return;
    }
    setState(() => _draftIds.removeAt(index));
  }

  Future<void> _apply() async {
    await _store.setActiveOptions(_draftIds);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reset() async {
    setState(() {
      _draftIds = List<String>.from(ShellNavCatalog.defaultActiveIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = ShellNavCatalog.groupedOptions();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingLg,
              AppDimensions.spacingSm,
              AppDimensions.spacingLg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '自定义底栏',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  '选择 ${ShellNavConfigStore.minTabs}–${ShellNavConfigStore.maxTabs} 个入口，长按底栏可随时调整',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _PreviewStrip(
                  draftIds: _draftIds,
                  canRemove: _canRemove,
                  onRemove: _removeAt,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  '已选 ${_draftIds.length}/${ShellNavConfigStore.maxTabs}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              children: [
                for (final group in ShellNavCatalog.groupOrder)
                  if (grouped[group]?.isNotEmpty ?? false) ...[
                    _GroupHeader(title: group),
                    for (final option in grouped[group]!)
                      _OptionTile(
                        option: option,
                        active: _draftIds.contains(option.id),
                        disabled: !_draftIds.contains(option.id) && !_canAddMore,
                        isDark: isDark,
                        onTap: () => _toggle(option.id),
                      ),
                  ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingLg,
              AppDimensions.spacingSm,
              AppDimensions.spacingLg,
              AppDimensions.spacingLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: '恢复默认',
                    expand: true,
                    onPressed: _reset,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: GlassButton(
                    label: '完成',
                    filled: true,
                    expand: true,
                    onPressed: _draftIds.isEmpty ? null : _apply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip({
    required this.draftIds,
    required this.canRemove,
    required this.onRemove,
  });

  final List<String> draftIds;
  final bool canRemove;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Wrap(
        spacing: AppDimensions.spacingSm,
        runSpacing: AppDimensions.spacingSm,
        children: [
          for (var i = 0; i < draftIds.length; i++)
            _PreviewChip(
              option: ShellNavCatalog.optionById(draftIds[i]),
              showRemove: canRemove,
              onRemove: () => onRemove(i),
            ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.option,
    required this.showRemove,
    required this.onRemove,
  });

  final ShellNavOption option;
  final bool showRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(option.icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            option.label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          if (showRemove) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: AppColors.accent.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Text(
        title,
        style: AppTextStyles.bodySecondary.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.active,
    required this.disabled,
    required this.isDark,
    required this.onTap,
  });

  final ShellNavOption option;
  final bool active;
  final bool disabled;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active
        ? AppColors.accent
        : (disabled
            ? AppColors.textTertiary
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Icon(option.icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? AppColors.accent
                        : (disabled
                            ? AppColors.textTertiary
                            : AppColors.textPrimary),
                  ),
                ),
              ),
              Icon(
                active ? Icons.check_circle : Icons.circle_outlined,
                size: 22,
                color: active
                    ? AppColors.accent
                    : (disabled
                        ? AppColors.textTertiary
                        : AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
