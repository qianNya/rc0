import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../widgets/scene_form_sections.dart';

class SceneCreatePage extends StatefulWidget {
  const SceneCreatePage({
    super.key,
    this.initialDescription,
    this.initialCoverPath,
  });

  final String? initialDescription;
  final String? initialCoverPath;

  @override
  State<SceneCreatePage> createState() => _SceneCreatePageState();
}

class _SceneCreatePageState extends State<SceneCreatePage> {
  final _repo = SceneRepository.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formData = SceneFormData();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    if (widget.initialCoverPath != null) {
      _formData.coverPath = widget.initialCoverPath!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveLocalExtras(String sceneId) async {
    if (_formData.coverPath.isNotEmpty) {
      await SceneLocalStore.instance.setLocalCoverPath(
        sceneId,
        _formData.coverPath,
      );
    }
    if (_formData.referencePaths.isNotEmpty) {
      await SceneLocalStore.instance.setReferenceImageUrls(
        sceneId,
        _formData.referencePaths,
      );
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写场景名称')));
      return;
    }

    setState(() => _saving = true);
    final result = await _repo.create(
      title: title,
      coverUrl: _formData.coverPath,
      description: _descriptionController.text.trim(),
      category: _formData.category,
      tags: _formData.tags,
      themes: _formData.themes,
      imageUrls: _formData.referencePaths,
      location: _formData.location,
      city: _formData.city,
      shootingTips: _formData.shootingTips,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    final scene = result.scene!;
    await _saveLocalExtras(scene.id);
    if (!mounted) return;
    context.pop(scene.id);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('创建场景'),
      onBack: () => popOrGoDiscovery(context),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          SceneFormSections(
            titleController: _titleController,
            descriptionController: _descriptionController,
            data: _formData,
            onChanged: () {},
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          PrimaryButton(
            label: _saving ? '保存中…' : '保存场景',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
