import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../character/domain/character_entry.dart';
import '../../../../character/presentation/widgets/character_picker_sheet.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../studio/domain/script_editor_selection.dart';
import '../script_editor/script_editor_actions.dart';

/// Screenplay-level character roster for the script editor and project settings.
class ScreenplayCharactersSection extends StatelessWidget {
  const ScreenplayCharactersSection({
    super.key,
    required this.draft,
    required this.onChanged,
    this.selection,
    this.actions,
    this.compact = false,
  });

  final ScreenplayDraft draft;
  final VoidCallback onChanged;
  final ScriptEditorSelection? selection;
  final ScriptEditorActions? actions;
  final bool compact;

  Future<void> _addCharacter(BuildContext context) async {
    final picked = await CharacterPickerSheet.show(
      context,
      selectedCharacterId: null,
    );
    if (!context.mounted || picked == null) return;
    _linkCharacter(picked);
    onChanged();
  }

  void _linkCharacter(CharacterEntry entry) {
    ensureDraftCharacterLinked(
      draft,
      id: entry.id,
      name: entry.name,
    );
  }

  void _removeCharacter(int id) {
    draft.linkedCharacters.removeWhere((c) => c.id == id);
    onChanged();
  }

  void _applyToSelectedFrame(int id, String name, {String appearance = ''}) {
    final sel = selection;
    final editorActions = actions;
    if (sel == null ||
        editorActions == null ||
        !sel.hasFrame ||
        sel.actIndex == null ||
        sel.sceneIndex == null ||
        sel.frameIndex == null) {
      return;
    }
    final frame = editorActions.draft.acts[sel.actIndex!].scenes[sel.sceneIndex!]
        .frames[sel.frameIndex!];
    frame.characterId = id;
    frame.characterName = name;
    if (frame.characterNote.trim().isEmpty && appearance.isNotEmpty) {
      frame.characterNote = appearance;
    }
    ensureDraftCharacterLinked(draft, id: id, name: name);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final characters = collectLinkedCharactersFromDraft(draft);
    final canApplyToFrame =
        selection?.hasFrame == true && actions != null;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.characterCardDark
            : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('剧本角色', style: AppTextStyles.label),
              ),
              TextButton.icon(
                onPressed: () => _addCharacter(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加角色'),
              ),
            ],
          ),
          if (characters.isEmpty)
            Text(
              '添加角色后可在分镜中快速绑定，保持角色一致性',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in characters)
                  InputChip(
                    label: Text(link.name),
                    avatar: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentLight,
                      child: Text(
                        link.name.isNotEmpty ? link.name.characters.first : '?',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    onPressed: canApplyToFrame
                        ? () => _applyToSelectedFrame(link.id, link.name)
                        : () => context.push(
                              AppRoutes.characterDetailPath(link.id),
                            ),
                    onDeleted: draft.linkedCharacters.any((c) => c.id == link.id)
                        ? () => _removeCharacter(link.id)
                        : null,
                  ),
              ],
            ),
          if (canApplyToFrame) ...[
            const SizedBox(height: 8),
            Text(
              '点击角色可绑定到当前分镜',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 11,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens character picker and links result to draft; returns picked entry.
Future<CharacterEntry?> pickAndLinkScreenplayCharacter(
  BuildContext context, {
  required ScreenplayDraft draft,
  int? selectedCharacterId,
}) async {
  final picked = await CharacterPickerSheet.show(
    context,
    selectedCharacterId: selectedCharacterId,
  );
  if (picked != null) {
    ensureDraftCharacterLinked(draft, id: picked.id, name: picked.name);
  }
  return picked;
}
