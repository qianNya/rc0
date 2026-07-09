import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../gallery/data/image_tags_repository.dart';
import '../../../gallery/domain/image_tag.dart';
import '../../../upload/data/image_pick_service.dart';
import '../../../upload/domain/upload_image_file.dart';
import '../../domain/character_entry.dart';

class CharacterFormData {
  CharacterFormData({
    this.coverPath = '',
    this.referencePaths = const [],
    this.linkedScreenplayLocalIds = const [],
    this.aliases = const [],
    this.selectedTagIds = const [],
    this.styleLabel = '',
  });

  String coverPath;
  List<String> referencePaths;
  List<String> linkedScreenplayLocalIds;
  List<String> aliases;
  List<int> selectedTagIds;
  String styleLabel;

  CharacterStyle get style => CharacterStyle.fromPresetLabel(styleLabel);

  Map<String, dynamic> get styleJson => style.toJson();
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
  final _aliasController = TextEditingController();
  final _tagsRepo = ImageTagsRepository.instance;
  List<ImageTag> _characterTags = const [];
  bool _loadingTags = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    setState(() => _loadingTags = true);
    await _tagsRepo.loadTags(namespace: 'character');
    if (!mounted) return;
    setState(() {
      _characterTags = List<ImageTag>.from(_tagsRepo.tags);
      _loadingTags = false;
    });
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

  void _addAlias() {
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) return;
    if (!widget.data.aliases.contains(alias)) {
      widget.data.aliases.add(alias);
    }
    _aliasController.clear();
    widget.onChanged();
    setState(() {});
  }

  void _toggleTag(ImageTag tag) {
    final ids = widget.data.selectedTagIds;
    if (ids.contains(tag.id)) {
      ids.remove(tag.id);
    } else {
      ids.add(tag.id);
    }
    widget.onChanged();
    setState(() {});
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Rc0Image(path: path, fit: BoxFit.cover);
    }
    if (!kIsWeb) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return const ColoredBox(color: Colors.black12);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final styles = AppCatalog.characterAiStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('封面图', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spacingSm),
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
        const SizedBox(height: AppDimensions.spacingLg),
        TextField(
          controller: widget.nameController,
          decoration: const InputDecoration(labelText: '角色名称 *'),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: widget.nameOrigController,
          decoration: const InputDecoration(labelText: '原名'),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text('分类标签', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spacingSm),
        if (_loadingTags)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (_characterTags.isEmpty)
          Text(
            '暂无角色标签，可稍后在图库标签中维护 namespace=character',
            style: AppTextStyles.bodySecondary,
          )
        else
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              for (final tag in _characterTags)
                FilterChip(
                  label: Text(tag.name),
                  selected: data.selectedTagIds.contains(tag.id),
                  onSelected: (_) => _toggleTag(tag),
                ),
            ],
          ),
        const SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _aliasController,
                decoration: const InputDecoration(labelText: '别名'),
                onSubmitted: (_) => _addAlias(),
              ),
            ),
            IconButton(onPressed: _addAlias, icon: const Icon(Icons.add)),
          ],
        ),
        if (data.aliases.isNotEmpty)
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              for (final alias in data.aliases)
                Chip(
                  label: Text(alias),
                  onDeleted: () {
                    data.aliases.remove(alias);
                    widget.onChanged();
                    setState(() {});
                  },
                ),
            ],
          ),
        const SizedBox(height: AppDimensions.spacingMd),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: data.styleLabel.isEmpty ? null : data.styleLabel,
          decoration: const InputDecoration(labelText: '视觉风格'),
          items: [
            for (final style in styles)
              DropdownMenuItem(value: style, child: Text(style)),
          ],
          onChanged: (v) {
            data.styleLabel = v ?? '';
            widget.onChanged();
            setState(() {});
          },
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: widget.summaryController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '简介',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: widget.appearanceController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '外观设定',
            hintText: '发色、服装、体型等，将注入 AI Prompt',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: widget.personalityController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '性格',
            alignLabelWithHint: true,
          ),
        ),
        if (widget.showSlug) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          TextField(
            controller: widget.slugController,
            decoration: const InputDecoration(labelText: 'Slug（URL 标识）'),
          ),
        ],
        const SizedBox(height: AppDimensions.spacingMd),
        DropdownButtonFormField<int>(
          // ignore: deprecated_member_use
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
        const SizedBox(height: AppDimensions.spacingLg),
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
        const SizedBox(height: AppDimensions.spacingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppDimensions.spacingSm,
            crossAxisSpacing: AppDimensions.spacingSm,
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
      ],
    );
  }

  Widget _coverPlaceholder() {
    return const Center(
      child: Icon(Icons.add_photo_alternate_outlined, size: 48),
    );
  }
}
