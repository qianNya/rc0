import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../widgets/scene_form_sections.dart';

class SceneEditPage extends StatefulWidget {
  const SceneEditPage({super.key, required this.sceneId});

  final String sceneId;

  @override
  State<SceneEditPage> createState() => _SceneEditPageState();
}

class _SceneEditPageState extends State<SceneEditPage> {
  final _repo = SceneRepository.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formData = SceneFormData();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await _repo.fetchDetail(widget.sceneId);
    final entry = result.scene;
    if (entry == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final cover = await SceneLocalStore.instance.localCoverPath(entry.id);
    final refs = await SceneLocalStore.instance.referenceImageUrls(entry.id);
    _titleController.text = entry.title;
    _descriptionController.text = entry.description;
    _formData
      ..category = entry.category
      ..coverPath = cover ?? entry.coverUrl
      ..referencePaths = refs.isNotEmpty ? refs : entry.imageUrls
      ..tags = List<String>.from(entry.tags)
      ..themes = List<String>.from(entry.themes)
      ..shootingTips = Map<String, String>.from(entry.shootingTips)
      ..location = entry.location
      ..city = entry.city
      ..latitude = entry.latitude
      ..longitude = entry.longitude;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    final result = await _repo.update(
      id: widget.sceneId,
      title: title,
      coverUrl: _formData.coverPath,
      description: _descriptionController.text.trim(),
      category: _formData.category,
      tags: _formData.tags,
      themes: _formData.themes,
      imageUrls: _formData.referencePaths,
      location: _formData.location,
      city: _formData.city,
      latitude: _formData.latitude,
      longitude: _formData.longitude,
      shootingTips: _formData.shootingTips,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    if (_formData.coverPath.isNotEmpty) {
      await SceneLocalStore.instance.setLocalCoverPath(
        widget.sceneId,
        _formData.coverPath,
      );
    }
    await SceneLocalStore.instance.setReferenceImageUrls(
      widget.sceneId,
      _formData.referencePaths,
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      overlayAppBar: true,
      title: const Text('编辑场景'),
      onBack: () => popOrGoDiscovery(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                wikiModeTagContentInsetHeight(context) + AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
              ),
              children: [
                SceneFormSections(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  data: _formData,
                  onChanged: () {},
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                PrimaryButton(
                  label: _saving ? '保存中…' : '保存修改',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
