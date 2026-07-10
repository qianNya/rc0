import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../core/domain/screenplay/screenplay_display.dart';
import 'content_card_shared.dart';
import 'glass/glass.dart';
import 'profile_widgets.dart';
import 'pose_cover_image.dart';

/// Layout for [GlassFeedCard].
enum GlassFeedCardLayout {
  /// Title + likes on image scrim (template market / discovery).
  overlay,

  /// Glass card with cover + footer metrics (works library).
  library,
}

/// Image-first feed tile shared across template market, discovery, and works.
class GlassFeedCard extends StatefulWidget {
  const GlassFeedCard({
    super.key,
    required this.screenplay,
    this.layout = GlassFeedCardLayout.overlay,
    this.badge,
    this.onTap,
    this.onMore,
    this.onDelete,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedToggle,
    this.onLongPress,
  });

  final Screenplay screenplay;
  final GlassFeedCardLayout layout;
  final ContentBadgeType? badge;
  final VoidCallback? onTap;
  final VoidCallback? onMore;
  final VoidCallback? onDelete;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPress;

  @override
  State<GlassFeedCard> createState() => _GlassFeedCardState();
}

class _GlassFeedCardState extends State<GlassFeedCard> {
  bool _pressed = false;

  String get _title => widget.screenplay.title.trim().isEmpty
      ? '未命名剧本'
      : widget.screenplay.title.trim();

  String? get _visibilityBadgeLabel {
    if (widget.layout != GlassFeedCardLayout.library) return null;
    if (widget.screenplay.isLocal) return '草稿';
    if (widget.screenplay.visibility == 0) return '非公开';
    return '公开';
  }

  void _handleTap() {
    if (widget.selectionMode) {
      widget.onSelectedToggle?.call();
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    context.push(AppRoutes.script(widget.screenplay.detailRouteId));
  }

  Future<void> _showDraftMenu() async {
    final action = await showGlassSheet<String>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassListRow(
            leading: const Icon(Icons.edit_outlined),
            title: '继续编辑',
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          if (widget.onDelete != null)
            GlassListRow(
              leading: const Icon(Icons.delete_outline),
              iconColor: AppColors.error,
              title: '删除',
              onTap: () => Navigator.pop(context, 'delete'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      _handleTap();
    } else if (action == 'delete') {
      widget.onDelete?.call();
    }
  }

  Future<void> _showLibraryMenu() async {
    final action = await showGlassSheet<String>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.screenplay.isLocal && !widget.screenplay.isPublished)
            GlassListRow(
              leading: const Icon(Icons.edit_outlined),
              title: '继续编辑',
              onTap: () => Navigator.pop(context, 'edit'),
            ),
          if (widget.onMore != null)
            GlassListRow(
              leading: const Icon(Icons.visibility_outlined),
              title: '可见性设置',
              onTap: () => Navigator.pop(context, 'visibility'),
            ),
          if (widget.onDelete != null)
            GlassListRow(
              leading: const Icon(Icons.delete_outline),
              iconColor: AppColors.error,
              title: '删除',
              onTap: () => Navigator.pop(context, 'delete'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'edit':
        _handleTap();
      case 'visibility':
        widget.onMore?.call();
      case 'delete':
        widget.onDelete?.call();
    }
  }

  bool get _hasLibraryMenu =>
      widget.onMore != null ||
      widget.onDelete != null ||
      (widget.screenplay.isLocal && !widget.screenplay.isPublished);

  @override
  Widget build(BuildContext context) {
    if (widget.layout == GlassFeedCardLayout.library) {
      return _buildLibraryCard(context);
    }
    return _buildOverlayCard(context);
  }

  Widget _buildOverlayCard(BuildContext context) {
    final view = widget.screenplay.toCardView();
    final radius = BorderRadius.circular(AppDimensions.radiusXl);
    final duration = widget.screenplay.durationLabel;
    final author = view.author.trim().isEmpty ? '创作者' : view.author.trim();
    final leftInset = widget.selectionMode
        ? AppDimensions.spacingXl + AppDimensions.spacingSm
        : AppDimensions.spacingSm;

    return _PressableCard(
      pressed: _pressed,
      onPressedChanged: (v) => setState(() => _pressed = v),
      onTap: _handleTap,
      onLongPress: widget.selectionMode
          ? widget.onSelectedToggle
          : widget.onLongPress,
      selected: widget.selectionMode && widget.selected,
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PoseCoverImage(
            imagePath: widget.screenplay.effectiveCoverImagePath,
            expand: true,
            borderRadius: AppDimensions.radiusXl,
          ),
          const Positioned.fill(child: _BottomCaptionScrim()),
          if (widget.selectionMode)
            Positioned(
              top: AppDimensions.spacingSm,
              left: AppDimensions.spacingSm,
              child: Checkbox(
                value: widget.selected,
                onChanged: (_) => widget.onSelectedToggle?.call(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          if (duration.isNotEmpty || widget.badge != null)
            Positioned(
              top: AppDimensions.spacingSm,
              left: leftInset,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (duration.isNotEmpty) _OverlayPill(label: duration),
                  if (duration.isNotEmpty && widget.badge != null)
                    const SizedBox(width: AppDimensions.spacingXs),
                  if (widget.badge != null)
                    ContentCardBadge(type: widget.badge!),
                ],
              ),
            ),
          Positioned(
            top: AppDimensions.spacingSm,
            right: AppDimensions.spacingSm,
            child: _OverlayPill(
              label: '查看创作过程',
              onTap: _handleTap,
            ),
          ),
          Positioned(
            left: AppDimensions.spacingSm,
            right: AppDimensions.spacingSm,
            bottom: AppDimensions.spacingSm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@$author',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        view.title,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    const Icon(
                      Icons.star_border_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatFeedCount(view.favorites),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(BuildContext context) {
    final badgeLabel = _visibilityBadgeLabel;

    return GlassCard(
      padding: EdgeInsets.zero,
      selected: widget.selected,
      onTap: widget.selectionMode ? widget.onSelectedToggle : _handleTap,
      onLongPress: widget.selectionMode
          ? widget.onSelectedToggle
          : widget.onLongPress ?? widget.onDelete,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PoseCoverImage(
                  imagePath: widget.screenplay.effectiveCoverImagePath,
                  expand: true,
                  borderRadius: AppDimensions.radiusXl,
                ),
                const Positioned.fill(child: _BottomCaptionScrim()),
                if (badgeLabel != null)
                  Positioned(
                    top: AppDimensions.spacingSm,
                    right: AppDimensions.spacingSm,
                    child: _VisibilityBadge(label: badgeLabel),
                  ),
                if (widget.selectionMode)
                  Positioned(
                    top: AppDimensions.spacingSm,
                    left: AppDimensions.spacingSm,
                    child: AnimatedScale(
                      duration: AppMotion.fast,
                      scale: widget.selected ? 1 : 0.9,
                      child: Checkbox(
                        value: widget.selected,
                        onChanged: (_) => widget.onSelectedToggle?.call(),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                Positioned(
                  left: AppDimensions.spacingSm,
                  right: AppDimensions.spacingSm,
                  bottom: AppDimensions.spacingSm,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.movie_creation_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          widget.screenplay.hierarchySummary,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingSm + 2,
              AppDimensions.spacingSm + 2,
              AppDimensions.spacingSm,
              AppDimensions.spacingSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.label.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      widget.screenplay.likes.toString(),
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      widget.screenplay.views.toString(),
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: !_hasLibraryMenu
                          ? null
                          : () {
                              if (widget.onMore == null &&
                                  widget.onDelete != null &&
                                  widget.screenplay.isLocal) {
                                _showDraftMenu();
                              } else {
                                _showLibraryMenu();
                              }
                            },
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 28,
                      ),
                      icon: const Icon(Icons.more_horiz, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableCard extends StatelessWidget {
  const _PressableCard({
    required this.pressed,
    required this.onPressedChanged,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.selected = false,
    required this.borderRadius,
  });

  final bool pressed;
  final ValueChanged<bool> onPressedChanged;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool selected;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) => onPressedChanged(false),
      onTapCancel: () => onPressedChanged(false),
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: selected
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: ClipRRect(borderRadius: borderRadius, child: child),
        ),
      ),
    );
  }
}

class _BottomCaptionScrim extends StatelessWidget {
  const _BottomCaptionScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.heroScrimTop,
            AppColors.heroScrimMid,
            AppColors.heroScrimBottom,
          ],
          stops: [0.35, 0.72, 1],
        ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimensions.tabFloatingRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
