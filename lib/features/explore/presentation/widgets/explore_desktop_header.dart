import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../auth/data/auth_repository.dart';
import 'explore_desktop_card.dart';

/// Desktop explore chrome — wiki floating title + search row.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                    child: WikiModeTagTitleChip(text: '发现'),
                  ),
                ),
                WikiModeTagIconButton(
                  icon: Icons.movie_creation_outlined,
                  tooltip: '创作',
                  onPressed: widget.onCreate,
                ),
                WikiModeTagIconButton(
                  icon: Icons.notifications_outlined,
                  tooltip: '通知',
                  onPressed: () => context.push(AppRoutes.messages),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: nickname,
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.profile),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.accentLight,
                        backgroundImage: profile?.avatar != null &&
                                profile!.avatar.isNotEmpty
                            ? NetworkImage(profile.avatar)
                            : null,
                        child: profile?.avatar == null ||
                                profile!.avatar.isEmpty
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
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ExploreDesktopChrome.gap,
            AppDimensions.spacingSm,
            ExploreDesktopChrome.gap,
            0,
          ),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
      ],
    );
  }
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}
