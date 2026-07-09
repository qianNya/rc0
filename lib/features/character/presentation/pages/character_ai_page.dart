import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class CharacterAiPage extends StatefulWidget {
  const CharacterAiPage({super.key});

  @override
  State<CharacterAiPage> createState() => _CharacterAiPageState();
}

class _CharacterAiPageState extends State<CharacterAiPage> {
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
        ..showSnackBar(const SnackBar(content: Text('请输入角色描述')));
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

  void _saveCharacter() {
    final summary = _descriptionController.text.trim();
    final style = AppCatalog.characterAiStyles[_styleIndex];
    final uri = Uri(
      path: AppRoutes.characterCreate,
      queryParameters: {
        if (summary.isNotEmpty) 'summary': summary,
        'style': style,
      },
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DesktopStackScaffold(
      title: const Text('AI 角色'),
      onBack: () => popOrGoDiscovery(context),
      body: ColoredBox(
        color: AppColors.pageBackground,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          children: [
            Text('角色描述', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '白发少女\n海边\n蓝眼睛\n孤独感\n电影感\n长裙',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Text('参考风格', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppCatalog.characterAiStyles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _styleIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _styleIndex = index),
                    child: Container(
                      width: 88,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.characterCardDark
                            : AppColors.surfaceSecondary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXl),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.palette_outlined,
                            color: selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppCatalog.characterAiStyles[index],
                            style: AppTextStyles.label.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('生成数量', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (var i = 0; i < AppCatalog.characterAiCounts.length; i++)
                  ButtonSegment(
                    value: i,
                    label: Text('${AppCatalog.characterAiCounts[i]}张'),
                  ),
              ],
              selected: {_countIndex},
              onSelectionChanged: (value) {
                setState(() => _countIndex = value.first);
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _generating ? '生成中…' : '生成角色',
              onPressed: _generating ? null : _generate,
            ),
            const SizedBox(height: 8),
            Text(
              '今日剩余 10 次生成机会',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _results.length <= 1 ? 1 : 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final selected = _selectedResultIndexes.contains(index);
                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PlaceholderImage(
                          aspectRatio: 3 / 4,
                          borderRadius: AppDimensions.radiusXl,
                        ),
                        if (selected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.accent,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新生成'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: '保存角色',
                      onPressed:
                          _selectedResultIndexes.isEmpty ? null : _saveCharacter,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
