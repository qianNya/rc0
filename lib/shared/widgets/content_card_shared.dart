import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/data/app_catalog.dart';
import '../../core/domain/screenplay/screenplay.dart';
import 'glass/glass_sheet.dart';
import 'profile_widgets.dart';

enum FeedTypeBadgeKind { script, template }

class FeedTypeBadge extends StatelessWidget {
  const FeedTypeBadge({super.key, required this.kind});

  final FeedTypeBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final isScript = kind == FeedTypeBadgeKind.script;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isScript ? AppColors.accent : AppColors.badgeTemplate,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isScript ? '剧本' : 'Template',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class FeedAuthorRow extends StatelessWidget {
  const FeedAuthorRow({
    super.key,
    required this.author,
    this.avatarUrl,
    this.light = false,
    this.showLevel = false,
  });

  final String author;
  final String? avatarUrl;
  final bool light;
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    final name = author.isNotEmpty ? author : AppCatalog.placeholderAuthor;
    final textColor = light ? Colors.white70 : AppColors.textSecondary;
    final resolvedAvatar = avatarUrl?.trim();
    final hasAvatar = resolvedAvatar != null && resolvedAvatar.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: light ? Colors.white24 : AppColors.placeholder,
          backgroundImage:
              hasAvatar ? NetworkImage(resolvedAvatar) : null,
          child: hasAvatar
              ? null
              : Icon(
                  Icons.person,
                  size: 14,
                  color: light ? Colors.white : AppColors.textSecondary,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 13, color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showLevel)
          Text(
            'LV.${AppCatalog.placeholderLevel}',
            style: TextStyle(
              fontSize: 11,
              color: light ? Colors.white70 : AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

String formatFeedCount(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

/// Grid child aspect ratio for feed cards with cover + title + author + stats.
double feedGridChildAspectRatio(
  int crossAxisCount, {
  bool overlayMetrics = false,
}) {
  if (overlayMetrics) {
    if (crossAxisCount >= 6) return 0.70;
    if (crossAxisCount >= 5) return 0.72;
    if (crossAxisCount >= 4) return 0.74;
    if (crossAxisCount >= 3) return 0.76;
    return 0.78;
  }
  if (crossAxisCount >= 6) return 0.58;
  if (crossAxisCount >= 5) return 0.60;
  if (crossAxisCount >= 4) return 0.62;
  if (crossAxisCount >= 3) return 0.66;
  return 0.68;
}

String feedStructureLabel(Screenplay screenplay) {
  final acts = screenplay.actCount;
  final scenes = screenplay.sceneCount;
  final frames = screenplay.frameCount;
  if (acts <= 0 && scenes <= 0 && frames <= 0) return '剧本';
  if (acts > 0 && scenes > 0) return '$acts幕 · $scenes场';
  if (frames > 0) return '$frames画';
  if (acts > 0) return '$acts幕';
  return '$scenes场';
}

class FeedEngagementRow extends StatelessWidget {
  const FeedEngagementRow({
    super.key,
    required this.likes,
    required this.comments,
    this.light = false,
    this.showBookmark = false,
    this.bookmarks = 0,
    this.onMore,
  });

  final int likes;
  final int comments;
  final bool light;
  final bool showBookmark;
  final int bookmarks;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final iconColor = light ? Colors.white70 : AppColors.textSecondary;
    final textStyle = TextStyle(
      fontSize: 12,
      color: light ? Colors.white70 : AppColors.textSecondary,
    );

    return Row(
      children: [
        _FeedStat(icon: Icons.favorite_border, value: formatFeedCount(likes), iconColor: iconColor, textStyle: textStyle),
        const SizedBox(width: 16),
        _FeedStat(icon: Icons.chat_bubble_outline, value: formatFeedCount(comments), iconColor: iconColor, textStyle: textStyle),
        if (showBookmark) ...[
          const SizedBox(width: 16),
          _FeedStat(icon: Icons.bookmark_border, value: formatFeedCount(bookmarks), iconColor: iconColor, textStyle: textStyle),
        ],
        const Spacer(),
        if (onMore != null)
          InkWell(
            onTap: onMore,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXs),
              child: Icon(Icons.more_horiz, size: 20, color: iconColor),
            ),
          ),
      ],
    );
  }
}

class _FeedStat extends StatelessWidget {
  const _FeedStat({
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.textStyle,
  });

  final IconData icon;
  final String value;
  final Color iconColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(value, style: textStyle),
      ],
    );
  }
}

class FeedForkButton extends StatelessWidget {
  const FeedForkButton({super.key, this.onPressed, this.loading = false});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.call_split, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                loading ? 'Fork 中…' : 'Fork',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentCardImageFooter extends StatelessWidget {
  const ContentCardImageFooter({
    super.key,
    required this.categoryLabel,
    required this.frameCount,
  });

  final String categoryLabel;
  final int frameCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              categoryLabel,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.movie_filter_outlined, size: 14, color: Colors.white70),
          if (frameCount > 0) ...[
            const SizedBox(width: 2),
            Text(
              '$frameCount',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class ContentCardBadge extends StatelessWidget {
  const ContentCardBadge({super.key, required this.type});

  final ContentBadgeType type;

  @override
  Widget build(BuildContext context) {
    final isHot = type == ContentBadgeType.hot;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHot ? AppColors.badgeHot : AppColors.badgeNew,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHot)
            const Padding(
              padding: EdgeInsets.only(right: 2),
              child: Icon(Icons.local_fire_department, size: 12, color: Colors.white),
            ),
          Text(
            isHot ? '热门' : '最新',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ContentCardEngagementRow extends StatelessWidget {
  const ContentCardEngagementRow({
    super.key,
    required this.likes,
    required this.comments,
    this.onMore,
  });

  final int likes;
  final int comments;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return FeedEngagementRow(
      likes: likes,
      comments: comments,
      onMore: onMore,
    );
  }
}

Future<void> showFeedMoreSheet(
  BuildContext context, {
  required Screenplay screenplay,
  VoidCallback? onFork,
  VoidCallback? onDelete,
}) {
  return showGlassSheet<void>(
    context,
    padding: kGlassSheetMenuPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('查看详情'),
          onTap: () {
            Navigator.pop(context);
            context.push(AppRoutes.script(screenplay.detailRouteId));
          },
        ),
        if (onFork != null)
          ListTile(
            leading: const Icon(Icons.call_split),
            title: const Text('Fork'),
            onTap: () {
              Navigator.pop(context);
              onFork();
            },
          ),
        if (onDelete != null)
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('删除', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
      ],
    ),
  );
}
