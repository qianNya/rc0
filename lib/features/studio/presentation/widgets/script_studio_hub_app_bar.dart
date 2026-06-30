import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/rc0_app_bar.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../screenplay_editor_host.dart';
import 'script_studio_hub_info_strip.dart';

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

  static const toolbarHeight = ScriptStudioHubInfoStrip.stripHeight;

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

    return Rc0AppBar(
      toolbarHeight: toolbarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 22),
        onPressed: onBack,
      ),
      leadingWidth: 48,
      title: ListenableBuilder(
        listenable: controller.titleController,
        builder: (context, _) {
          final rawTitle = controller.titleController.text.trim();
          final displayTitle = _bookTitle(rawTitle);
          final subtitle =
              '$statusLabel · ${draftHierarchySummary(draft)}';

          return Align(
            alignment: Alignment.centerLeft,
            child: ScriptStudioHubInfoStrip(
              height: toolbarHeight,
              draft: draft,
              title: displayTitle,
              subtitle: subtitle,
              onEditTap: onOpenSettings,
              scriptMenuItems: [
                for (final script in projects)
                  PopupMenuItem<String>(
                    value: script.id,
                    child: Text(
                      script.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onScriptSelected: (id) {
                if (id != scriptId) {
                  context.go(AppRoutes.studioEdit(id));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
