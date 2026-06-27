import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../domain/scene_utils.dart';
import '../../../upload/data/image_pick_service.dart';

class SceneFormData {
  SceneFormData({
    this.category = '',
    this.coverPath = '',
    this.referencePaths = const [],
    this.tags = const [],
    this.themes = const [],
    this.shootingTips = const {},
    this.location = '',
    this.city = '',
  });

  String category;
  String coverPath;
  List<String> referencePaths;
  List<String> tags;
  List<String> themes;
  Map<String, String> shootingTips;
  String location;
  String city;
}

class SceneFormSections extends StatefulWidget {
  const SceneFormSections({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.data,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final SceneFormData data;
  final VoidCallback onChanged;

  @override
  State<SceneFormSections> createState() => _SceneFormSectionsState();
}

class _SceneFormSectionsState extends State<SceneFormSections> {
  final _picker = ImagePickService();
  final _tagController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _tipControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.data.location;
    _cityController.text = widget.data.city;
    for (final key in const ['最佳时间', '推荐焦段', 'ISO', '快门', '构图', '灯光']) {
      _tipControllers[key] = TextEditingController(
        text: widget.data.shootingTips[key] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    for (final c in _tipControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCover() async {
    final result = await _picker.pickCover();
    if (result.added.isEmpty) return;
    widget.data.coverPath = result.added.first.path;
    widget.onChanged();
    setState(() {});
  }

  Future<void> _pickReference() async {
    if (widget.data.referencePaths.length >= 9) return;
    final result = await _picker.pickImages();
    if (result.added.isEmpty) return;
    widget.data.referencePaths = [
      ...widget.data.referencePaths,
      ...result.added.map((f) => f.path),
    ].take(9).toList();
    widget.onChanged();
    setState(() {});
  }

  void _syncTips() {
    widget.data.shootingTips = {
      for (final entry in _tipControllers.entries)
        if (entry.value.text.trim().isNotEmpty)
          entry.key: entry.value.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.titleController,
          decoration: const InputDecoration(labelText: '场景名称'),
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        DropdownButtonFormField<String>(
          value: widget.data.category.isEmpty ? null : widget.data.category,
          decoration: const InputDecoration(labelText: '分类'),
          items: [
            for (final c in sceneCategoryOptions())
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) {
            widget.data.category = v ?? '';
            widget.onChanged();
            setState(() {});
          },
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: widget.descriptionController,
          decoration: const InputDecoration(labelText: '简介'),
          maxLines: 3,
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: '地点'),
          onChanged: (v) {
            widget.data.location = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(labelText: '城市'),
          onChanged: (v) {
            widget.data.city = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text('封面', style: AppTextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCover,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: widget.data.coverPath.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      child: kIsWeb
                          ? Image.network(widget.data.coverPath, fit: BoxFit.cover)
                          : Image.file(
                              File(widget.data.coverPath),
                              fit: BoxFit.cover,
                            ),
                    )
                  : const Center(child: Icon(Icons.add_photo_alternate_outlined)),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text('参考图（最多9张）', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final path in widget.data.referencePaths)
              SizedBox(
                width: 72,
                height: 72,
                child: kIsWeb
                    ? Image.network(path, fit: BoxFit.cover)
                    : Image.file(File(path), fit: BoxFit.cover),
              ),
            if (widget.data.referencePaths.length < 9)
              InkWell(
                onTap: _pickReference,
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text('标签', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in widget.data.tags)
              Chip(
                label: Text(tag),
                onDeleted: () {
                  widget.data.tags = widget.data.tags.where((t) => t != tag).toList();
                  widget.onChanged();
                  setState(() {});
                },
              ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(hintText: '添加标签'),
                onSubmitted: (v) {
                  final tag = v.trim();
                  if (tag.isEmpty) return;
                  widget.data.tags = [...widget.data.tags, tag];
                  _tagController.clear();
                  widget.onChanged();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text('适用题材', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final theme in AppCatalog.sceneThemeTags)
              FilterChip(
                label: Text(theme),
                selected: widget.data.themes.contains(theme),
                onSelected: (selected) {
                  if (selected) {
                    widget.data.themes = [...widget.data.themes, theme];
                  } else {
                    widget.data.themes =
                        widget.data.themes.where((t) => t != theme).toList();
                  }
                  widget.onChanged();
                  setState(() {});
                },
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        Text('拍摄建议', style: AppTextStyles.label),
        const SizedBox(height: 8),
        for (final key in _tipControllers.keys) ...[
          TextField(
            controller: _tipControllers[key],
            decoration: InputDecoration(labelText: key),
            onChanged: (_) {
              _syncTips();
              widget.onChanged();
            },
          ),
          const SizedBox(height: AppDimensions.spacingSm),
        ],
      ],
    );
  }
}
