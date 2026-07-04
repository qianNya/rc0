import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/glass/glass_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/asset_repository.dart';
import '../../domain/user_asset_category.dart';
import '../../domain/user_asset_item.dart';

Future<void> showAssetCategorySheet(
  BuildContext context, {
  UserAssetCategory? existing,
}) {
  return showGlassScrollSheet<void>(
    context,
    maxHeightFraction: 0.45,
    builder: (context, maxHeight) => _AssetCategorySheetBody(
      maxHeight: maxHeight,
      existing: existing,
    ),
  );
}

class _AssetCategorySheetBody extends StatefulWidget {
  const _AssetCategorySheetBody({
    required this.maxHeight,
    this.existing,
  });

  final double maxHeight;
  final UserAssetCategory? existing;

  @override
  State<_AssetCategorySheetBody> createState() => _AssetCategorySheetBodyState();
}

class _AssetCategorySheetBodyState extends State<_AssetCategorySheetBody> {
  final _repo = AssetRepository.instance;
  final _labelController = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写分类名称')));
      return;
    }

    setState(() => _saving = true);
    if (_isEdit) {
      final error = await _repo.updateUserCategory(
        id: widget.existing!.id,
        label: label,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
        return;
      }
    } else {
      await _repo.createUserCategory(label: label);
      if (!mounted) return;
      setState(() => _saving = false);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? '编辑分类' : '新建资产分类',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            GlassTextField(
              controller: _labelController,
              hintText: '例如：轨道、摇臂、收音',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const Spacer(),
            PrimaryButton(
              label: _saving ? '保存中…' : '保存',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAssetItemSheet(
  BuildContext context, {
  required String categoryId,
  UserAssetItem? existing,
}) {
  return showGlassScrollSheet<void>(
    context,
    maxHeightFraction: 0.62,
    builder: (context, maxHeight) => _AssetItemSheetBody(
      maxHeight: maxHeight,
      categoryId: categoryId,
      existing: existing,
    ),
  );
}

class _AssetItemSheetBody extends StatefulWidget {
  const _AssetItemSheetBody({
    required this.maxHeight,
    required this.categoryId,
    this.existing,
  });

  final double maxHeight;
  final String categoryId;
  final UserAssetItem? existing;

  @override
  State<_AssetItemSheetBody> createState() => _AssetItemSheetBodyState();
}

class _AssetItemSheetBodyState extends State<_AssetItemSheetBody> {
  final _repo = AssetRepository.instance;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _brandController.text = existing.brand;
      _modelController.text = existing.model;
      _notesController.text = existing.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请填写资产名称')));
      return;
    }

    setState(() => _saving = true);
    if (_isEdit) {
      final error = await _repo.updateItem(
        widget.existing!.copyWith(
          name: name,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
        return;
      }
    } else {
      await _repo.createItem(
        categoryId: widget.categoryId,
        name: name,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _saving = false);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? '编辑资产' : '添加资产',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            GlassTextField(
              controller: _nameController,
              hintText: '名称',
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            GlassTextField(
              controller: _brandController,
              hintText: '品牌（可选）',
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            GlassTextField(
              controller: _modelController,
              hintText: '型号（可选）',
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            GlassTextField(
              controller: _notesController,
              hintText: '备注（可选）',
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            PrimaryButton(
              label: _saving ? '保存中…' : '保存',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
