import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/character_utils.dart';
import '../../../upload/data/image_pick_service.dart';
import '../../../upload/domain/upload_image_file.dart';

class CharacterFormData {
  CharacterFormData({
    this.category = '',
    this.coverPath = '',
    this.referencePaths = const [],
    this.linkedScreenplayLocalIds = const [],
    this.aliases = const [],
  });

  String category;
  String coverPath;
  List<String> referencePaths;
  List<String> linkedScreenplayLocalIds;
  List<String> aliases;
}

class CharacterFormSections extends StatefulWidget {
  const CharacterFormSections({
    super.key,
    required this.nameController,
    required this.nameOrigController,
    required this.slugController,
    required this.summaryController,
    required this.appearanceController,
    required this.personalityController,
    required this.data,
    required this.gender,
    required this.onGenderChanged,
    required this.onChanged,
    this.showSlug = true,
  });

  final TextEditingController nameController;
  final TextEditingController nameOrigController;
  final TextEditingController slugController;
  final TextEditingController summaryController;
  final TextEditingController appearanceController;
  final TextEditingController personalityController;
  final CharacterFormData data;
  final int gender;
  final ValueChanged<int> onGenderChanged;
  final VoidCallback onChanged;
  final bool showSlug;

  @override
  State<CharacterFormSections> createState() => _CharacterFormSectionsState();
}

class _CharacterFormSectionsState extends State<CharacterFormSections> {
  final _picker = ImagePickService();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
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
    final remaining = 9 - widget.data.referencePaths.length;
    widget.data.referencePaths.addAll(
      result.added.take(remaining).map((UploadImageFile f) => f.path),
    );
    widget.onChanged();
    setState(() {});
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) return;
    if (!widget.data.aliases.contains(tag)) {
      widget.data.aliases.add(tag);
    }
    _tagController.clear();
    widget.onChanged();
    setState(() {});
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    if (!kIsWeb) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return const ColoredBox(color: Colors.black12);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final categories = characterCategoryOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('封面图', style: AppTextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickCover,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              clipBehavior: Clip.antiAlias,
              child: data.coverPath.isNotEmpty
                  ? _buildImage(data.coverPath)
                  : _coverPlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: widget.nameController,
          decoration: const InputDecoration(labelText: '角色名称 *'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: data.category.isEmpty ? null : data.category,
          decoration: const InputDecoration(labelText: '分类'),
          items: [
            for (final c in categories)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) {
            data.category = v ?? '';
            widget.onChanged();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(labelText: '标签'),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
          ],
        ),
        if (data.aliases.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in data.aliases)
                Chip(
                  label: Text(tag),
                  onDeleted: () {
                    data.aliases.remove(tag);
                    widget.onChanged();
                    setState(() {});
                  },
                ),
            ],
          ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.summaryController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '简介',
            alignLabelWithHint: true,
          ),
        ),
        if (widget.showSlug) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.slugController,
            decoration: const InputDecoration(labelText: 'Slug（URL 标识）'),
          ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: widget.gender,
          decoration: const InputDecoration(labelText: '性别'),
          items: const [
            DropdownMenuItem(value: 0, child: Text('未知')),
            DropdownMenuItem(value: 1, child: Text('男')),
            DropdownMenuItem(value: 2, child: Text('女')),
            DropdownMenuItem(value: 3, child: Text('其他')),
          ],
          onChanged: (v) => widget.onGenderChanged(v ?? 0),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('参考图', style: AppTextStyles.label),
            const Spacer(),
            Text(
              '${data.referencePaths.length}/9',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: data.referencePaths.length < 9
              ? data.referencePaths.length + 1
              : 9,
          itemBuilder: (context, index) {
            if (index == data.referencePaths.length) {
              return InkWell(
                onTap: _pickReference,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(Icons.add),
                ),
              );
            }
            final path = data.referencePaths[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  child: _buildImage(path),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      data.referencePaths.removeAt(index);
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text('关联剧本', style: AppTextStyles.label),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('剧本关联将在后续版本完善')),
              );
          },
          icon: const Icon(Icons.movie_creation_outlined),
          label: Text(
            data.linkedScreenplayLocalIds.isEmpty
                ? '添加剧本'
                : '已关联 ${data.linkedScreenplayLocalIds.length} 个剧本',
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
    return const Center(
      child: Icon(Icons.add_photo_alternate_outlined, size: 48),
    );
  }
}

List<String> buildAliasesFromForm(CharacterFormData data) {
  final aliases = List<String>.from(data.aliases);
  if (data.category.isNotEmpty && !aliases.contains(data.category)) {
    aliases.insert(0, data.category);
  }
  return aliases;
}
