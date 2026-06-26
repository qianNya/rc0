import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/character_repository.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({super.key, this.workId});

  final int? workId;

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final _repo = CharacterRepository.instance;
  final _nameController = TextEditingController();
  final _nameOrigController = TextEditingController();
  final _slugController = TextEditingController();
  final _summaryController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  int _gender = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameOrigController.dispose();
    _slugController.dispose();
    _summaryController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写角色名')));
      return;
    }

    setState(() => _saving = true);
    final result = await _repo.create(
      workId: widget.workId ?? 0,
      name: name,
      nameOrig: _nameOrigController.text.trim(),
      slug: _slugController.text.trim(),
      gender: _gender,
      summary: _summaryController.text.trim(),
      appearance: _appearanceController.text.trim(),
      personality: _personalityController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    context.pop(result.character?.id);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('新建角色'),
      onBack: () => popOrGoDiscovery(context),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '角色名 *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameOrigController,
            decoration: const InputDecoration(labelText: '原名 / 英文名'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _slugController,
            decoration: const InputDecoration(labelText: 'Slug（URL 标识）'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _gender,
            decoration: const InputDecoration(labelText: '性别'),
            items: const [
              DropdownMenuItem(value: 0, child: Text('未知')),
              DropdownMenuItem(value: 1, child: Text('男')),
              DropdownMenuItem(value: 2, child: Text('女')),
              DropdownMenuItem(value: 3, child: Text('其他')),
            ],
            onChanged: (v) => setState(() => _gender = v ?? 0),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '简介',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _appearanceController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '外观设定',
              hintText: '发色、服装等，供 AI 生图参考',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _personalityController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '性格 / 人设',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _saving ? '保存中…' : '创建',
            onPressed: _saving ? null : _save,
          ),
          if (widget.workId == null) ...[
            const SizedBox(height: 12),
            Text(
              '未选择 IP 时将创建独立 OC（work_id=0）',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}
