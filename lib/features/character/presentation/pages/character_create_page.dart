import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../widgets/character_form_sections.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({
    super.key,
    this.workId,
    this.initialSummary,
    this.initialCoverPath,
  });

  final int? workId;
  final String? initialSummary;
  final String? initialCoverPath;

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
  final _formData = CharacterFormData();
  int _gender = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSummary != null) {
      _summaryController.text = widget.initialSummary!;
    }
    if (widget.initialCoverPath != null) {
      _formData.coverPath = widget.initialCoverPath!;
    }
  }

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

  Future<void> _saveLocalExtras(int characterId) async {
    if (_formData.coverPath.isNotEmpty) {
      await CharacterLocalStore.instance.setLocalCoverPath(
        characterId,
        _formData.coverPath,
      );
    }
    if (_formData.referencePaths.isNotEmpty) {
      await CharacterLocalStore.instance.setReferenceImageUrls(
        characterId,
        _formData.referencePaths,
      );
    }
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
      aliases: buildAliasesFromForm(_formData),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    final id = result.character?.id;
    if (id != null) {
      await _saveLocalExtras(id);
    }
    if (!mounted) return;
    context.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('新建角色'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(
            _saving ? '保存中…' : '保存',
            style: AppTextStyles.label.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          CharacterFormSections(
            nameController: _nameController,
            nameOrigController: _nameOrigController,
            slugController: _slugController,
            summaryController: _summaryController,
            appearanceController: _appearanceController,
            personalityController: _personalityController,
            data: _formData,
            gender: _gender,
            onGenderChanged: (v) => setState(() => _gender = v),
            onChanged: () => setState(() {}),
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
