import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../widgets/character_form_sections.dart';
import '../../../../shared/widgets/glass/glass.dart';

class CharacterEditPage extends StatefulWidget {
  const CharacterEditPage({super.key, required this.characterId});

  final int characterId;

  @override
  State<CharacterEditPage> createState() => _CharacterEditPageState();
}

class _CharacterEditPageState extends State<CharacterEditPage> {
  final _repo = CharacterRepository.instance;
  final _nameController = TextEditingController();
  final _nameOrigController = TextEditingController();
  final _slugController = TextEditingController();
  final _summaryController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _formData = CharacterFormData();
  CharacterEntry? _entry;
  bool _loading = true;
  String? _error;
  int _gender = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.fetchDetail(widget.characterId);
    final cover =
        await CharacterLocalStore.instance.localCoverPath(widget.characterId);
    final refs = await CharacterLocalStore.instance
        .referenceImageUrls(widget.characterId);
    if (!mounted) return;

    final entry = result.character;
    if (entry == null) {
      setState(() {
        _error = result.error ?? '角色不存在';
        _loading = false;
      });
      return;
    }

    _entry = entry;
    _nameController.text = entry.name;
    _nameOrigController.text = entry.nameOrig;
    _slugController.text = entry.slug;
    _summaryController.text = entry.summary;
    _appearanceController.text = entry.appearance;
    _personalityController.text = entry.personality;
    _gender = entry.gender;
    _formData.aliases = List<String>.from(entry.aliases);
    _formData.selectedTagIds = entry.tags.map((t) => t.id).toList();
    _formData.styleLabel = entry.styleLabel;
    _formData.coverPath = cover ?? entry.coverUrl;
    _formData.referencePaths = List<String>.from(refs);

    setState(() => _loading = false);
  }

  Future<void> _saveLocalExtras() async {
    if (_formData.coverPath.isNotEmpty) {
      await CharacterLocalStore.instance.setLocalCoverPath(
        widget.characterId,
        _formData.coverPath,
      );
    }
    await CharacterLocalStore.instance.setReferenceImageUrls(
      widget.characterId,
      _formData.referencePaths,
    );
  }

  Future<void> _save() async {
    final entry = _entry;
    if (entry == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写角色名')));
      return;
    }

    setState(() => _saving = true);
    final result = await _repo.update(
      id: entry.id,
      workId: entry.workId,
      name: name,
      nameOrig: _nameOrigController.text.trim(),
      slug: _slugController.text.trim(),
      gender: _gender,
      summary: _summaryController.text.trim(),
      appearance: _appearanceController.text.trim(),
      personality: _personalityController.text.trim(),
      coverUrl: _formData.coverPath,
      aliases: List<String>.from(_formData.aliases),
      styleJson: _formData.styleJson,
      visibility: entry.visibility,
      tagIds: List<int>.from(_formData.selectedTagIds),
    );
    await _saveLocalExtras();
    await _repo.uploadAndLinkReferenceImages(
      characterId: entry.id,
      localPaths: _formData.referencePaths,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('编辑角色'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        TextButton(
          onPressed: _saving || _loading ? null : _save,
          child: Text(
            _saving ? '保存中…' : '保存',
            style: AppTextStyles.label.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entry == null
              ? GlassEmptyState(
                  icon: Icons.person_outline,
                  title: _error ?? '角色不存在',
                  actionLabel: '重试',
                  onAction: _load,
                )
              : ListView(
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
                    GlassButton(
                filled: true,
                expand: true,
                      label: _saving ? '保存中…' : '保存修改',
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
    );
  }
}
