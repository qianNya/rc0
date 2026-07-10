import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import 'scene_form_sections.dart';
import '../../../../shared/widgets/glass/glass.dart';

/// Opens scene creation in a liquid-glass bottom sheet (same pattern as script project settings).
Future<String?> showSceneCreateSheet(
  BuildContext context, {
  String? initialDescription,
  String? initialCoverPath,
  double? initialLatitude,
  double? initialLongitude,
  String? initialCity,
  String? initialLocation,
  bool useRootNavigator = false,
}) {
  return showGlassScrollSheet<String?>(
    context,
    useRootNavigator: useRootNavigator,
    maxHeightFraction: 0.72,
    builder: (context, maxHeight) => _SceneCreateSheetBody(
      maxHeight: maxHeight,
      initialDescription: initialDescription,
      initialCoverPath: initialCoverPath,
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
      initialCity: initialCity,
      initialLocation: initialLocation,
    ),
  );
}

class SceneCreateFormPanel extends StatefulWidget {
  const SceneCreateFormPanel({
    super.key,
    this.initialDescription,
    this.initialCoverPath,
    this.initialLatitude,
    this.initialLongitude,
    this.initialCity,
    this.initialLocation,
    this.onSaved,
  });

  final String? initialDescription;
  final String? initialCoverPath;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialCity;
  final String? initialLocation;
  final ValueChanged<String>? onSaved;

  @override
  State<SceneCreateFormPanel> createState() => _SceneCreateFormPanelState();
}

class _SceneCreateFormPanelState extends State<SceneCreateFormPanel> {
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
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _formData.latitude = widget.initialLatitude;
      _formData.longitude = widget.initialLongitude;
    }
    if (widget.initialCity != null && widget.initialCity!.isNotEmpty) {
      _formData.city = widget.initialCity!;
    }
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _formData.location = widget.initialLocation!;
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

  Future<String?> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写场景名称')));
      return null;
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
      latitude: _formData.latitude,
      longitude: _formData.longitude,
      shootingTips: _formData.shootingTips,
    );
    if (!mounted) return null;
    setState(() => _saving = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return null;
    }

    final scene = result.scene!;
    await _saveLocalExtras(scene.id);
    widget.onSaved?.call(scene.id);
    return scene.id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SceneFormSections(
          titleController: _titleController,
          descriptionController: _descriptionController,
          data: _formData,
          onChanged: () {},
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        GlassButton(
                filled: true,
                expand: true,
          label: _saving ? '保存中…' : '保存场景',
          onPressed: _saving ? null : () => _save(),
        ),
      ],
    );
  }
}

class _SceneCreateSheetBody extends StatelessWidget {
  const _SceneCreateSheetBody({
    required this.maxHeight,
    this.initialDescription,
    this.initialCoverPath,
    this.initialLatitude,
    this.initialLongitude,
    this.initialCity,
    this.initialLocation,
  });

  final double maxHeight;
  final String? initialDescription;
  final String? initialCoverPath;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialCity;
  final String? initialLocation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          0,
          AppDimensions.spacingLg,
          AppDimensions.spacingSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              initialLatitude != null && initialLongitude != null
                  ? '在此位置创建场景'
                  : '创建场景',
              style: AppTextStyles.title.copyWith(fontSize: 17),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: SingleChildScrollView(
                child: SceneCreateFormPanel(
                  initialDescription: initialDescription,
                  initialCoverPath: initialCoverPath,
                  initialLatitude: initialLatitude,
                  initialLongitude: initialLongitude,
                  initialCity: initialCity,
                  initialLocation: initialLocation,
                  onSaved: (id) => Navigator.pop(context, id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
