import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/system_ui_style.dart';
import '../../../../shared/widgets/glass_app_bar_background.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../screenplay_editor_host.dart';

class ScriptStudioHubAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ScriptStudioHubAppBar({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onOpenSettings,
    this.hubFallbackTitle = '新建剧本',
    this.statusLabel = '创作中',
  });

  final ScreenplayEditorController controller;
  final VoidCallback onBack;
  final VoidCallback onOpenSettings;
  final String hubFallbackTitle;
  final String statusLabel;

  static const toolbarHeight = 52.0;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  String _bookTitle(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '《$hubFallbackTitle》';
    if (trimmed.startsWith('《') && trimmed.endsWith('》')) return trimmed;
    return '《$trimmed》';
  }

  @override
  Widget build(BuildContext context) {
    final projects = ScreenplayLocalRepository.instance.localScreenplays;
    final scriptId = controller.editScriptId ?? '';
    final draft = controller.draft;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      flexibleSpace: const GlassAppBarBackground(),
      systemOverlayStyle:
          AppSystemUi.styleFor(Theme.of(context).brightness),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 22),
        onPressed: onBack,
      ),
      title: ListenableBuilder(
        listenable: controller.titleController,
        builder: (context, _) {
          final rawTitle = controller.titleController.text.trim();
          final displayTitle = _bookTitle(rawTitle);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                tooltip: '切换剧本',
                offset: const Offset(0, 40),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        displayTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  for (final script in projects)
                    PopupMenuItem<String>(
                      value: script.id,
                      child: Text(
                        script.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onSelected: (id) {
                  if (id != scriptId) {
                    context.go(AppRoutes.studioEdit(id));
                  }
                },
              ),
              Text(
                '$statusLabel · ${draftHierarchySummary(draft)}',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenSettings,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
