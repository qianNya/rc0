import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../widgets/scene_create_sheet.dart';
import '../../../../shared/widgets/glass/glass.dart';

class SceneAiPage extends StatefulWidget {
  const SceneAiPage({super.key});

  @override
  State<SceneAiPage> createState() => _SceneAiPageState();
}

class _SceneAiPageState extends State<SceneAiPage> {
  final _descriptionController = TextEditingController();
  int _styleIndex = 0;
  int _countIndex = 1;
  bool _generating = false;
  Set<int> _selectedResultIndexes = {};
  List<String> _results = const [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  int get _generateCount => AppCatalog.characterAiCounts[_countIndex];

  Future<void> _generate() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请输入场景描述')));
      return;
    }

    setState(() {
      _generating = true;
      _results = const [];
      _selectedResultIndexes = {};
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _generating = false;
      _results = List.generate(_generateCount, (i) => 'placeholder_$i');
      _selectedResultIndexes = {0};
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedResultIndexes.contains(index)) {
        _selectedResultIndexes.remove(index);
      } else {
        _selectedResultIndexes.add(index);
      }
    });
  }

  Future<void> _saveScene() async {
    final summary = _descriptionController.text.trim();
    final style = AppCatalog.sceneAiStyles[_styleIndex];
    final description =
        summary.isNotEmpty ? '$summary\n风格：$style' : '风格：$style';
    await showSceneCreateSheet(
      context,
      initialDescription: description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      overlayAppBar: true,
      title: const Text('AI 场景'),
      onBack: () => popOrGoDiscovery(context),
      body: ColoredBox(
        color: AppColors.pageBackground,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            wikiModeTagContentInsetHeight(context) + AppDimensions.spacingMd,
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
          ),
          children: [
            Text('场景描述', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '描述你想要的拍摄场景、氛围与用途…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text('风格', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < AppCatalog.sceneAiStyles.length; i++)
                  ChoiceChip(
                    label: Text(AppCatalog.sceneAiStyles[i]),
                    selected: _styleIndex == i,
                    onSelected: (_) => setState(() => _styleIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text('生成数量', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (var i = 0; i < AppCatalog.characterAiCounts.length; i++)
                  ButtonSegment(
                    value: i,
                    label: Text('${AppCatalog.characterAiCounts[i]}'),
                  ),
              ],
              selected: {_countIndex},
              onSelectionChanged: (set) {
                setState(() => _countIndex = set.first);
              },
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            GlassButton(
                filled: true,
                expand: true,
              label: _generating ? '生成中…' : '生成场景',
              onPressed: _generating ? null : _generate,
            ),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              Text('生成结果', style: AppTextStyles.label),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final selected = _selectedResultIndexes.contains(index);
                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const PlaceholderImage(
                        aspectRatio: 3 / 4,
                        borderRadius: 12,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              GlassButton(
                filled: true,
                expand: true,
                label: '保存到我的场景',
                onPressed: _saveScene,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
