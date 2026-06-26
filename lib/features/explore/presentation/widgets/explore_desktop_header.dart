import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_brand_icon.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../shell/presentation/widgets/desktop_title_bar.dart';
import 'explore_desktop_card.dart';

/// 探索页桌面顶栏：导航、搜索、操作区，并兼作无边框窗口标题栏。
class ExploreDesktopHeader extends StatefulWidget {
  const ExploreDesktopHeader({
    super.key,
    required this.onSearch,
    required this.onCreate,
    this.initialQuery = '',
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onCreate;
  final String initialQuery;

  @override
  State<ExploreDesktopHeader> createState() => _ExploreDesktopHeaderState();
}

class _ExploreDesktopHeaderState extends State<ExploreDesktopHeader> {
  late final TextEditingController _searchController;
  final _focusNode = FocusNode();

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch() {
    widget.onSearch(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;
    final profile = auth.profile;
    final nickname = profile?.nickname ?? profile?.username ?? '未登录';
    final searchShortcut = _isMacOS ? '⌘ K' : 'Ctrl K';

    return ExploreDesktopCard(
      clipChild: true,
      child: DesktopMergedTitleBar(
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ExploreDesktopChrome.gap),
        child: Row(
          children: [
            IconButton(
              tooltip: '返回',
              onPressed: Navigator.of(context).canPop()
                  ? () => context.pop()
                  : null,
              icon: const Icon(Icons.arrow_back, size: 20),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: '前进',
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 20),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: ExploreDesktopChrome.gap),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Shortcuts(
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.keyK, control: true):
                        _SearchIntent(),
                    SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                        _SearchIntent(),
                  },
                  child: Actions(
                    actions: {
                      _SearchIntent: CallbackAction<_SearchIntent>(
                        onInvoke: (_) {
                          _focusNode.requestFocus();
                          return null;
                        },
                      ),
                    },
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: '搜索剧本、模板、场景、标签',
                        hintStyle: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                searchShortcut,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, size: 18),
                              onPressed: _submitSearch,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submitSearch(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: ExploreDesktopChrome.gap),
            FilledButton.icon(
              onPressed: widget.onCreate,
              icon: const AppBrandIcon(size: 18),
              label: const Text('创作'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                ),
              ),
            ),
            const SizedBox(width: ExploreDesktopChrome.gap),
            IconButton(
              tooltip: '通知',
              onPressed: () => context.push(AppRoutes.messages),
              icon: const Icon(Icons.notifications_outlined, size: 22),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: ExploreDesktopChrome.gap),
            Tooltip(
              message: nickname,
              child: InkWell(
                onTap: () => context.push(AppRoutes.profile),
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.accentLight,
                  backgroundImage: profile?.avatar != null &&
                          profile!.avatar.isNotEmpty
                      ? NetworkImage(profile.avatar)
                      : null,
                  child: profile?.avatar == null || profile!.avatar.isEmpty
                      ? Text(
                          nickname.isNotEmpty
                              ? nickname.characters.first
                              : '?',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (!_isMacOS) const SizedBox(width: ExploreDesktopChrome.gap),
          ],
        ),
      ),
      ),
    );
  }
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}
