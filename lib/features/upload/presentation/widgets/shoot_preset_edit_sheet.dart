import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/preset_catalog.dart';
import '../../../screenplay/data/shoot_preset_repository.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../../../screenplay/domain/shoot_preset.dart';
import 'upload_shoot_param_cards.dart';

enum ShootPresetEditMode { create, edit, customize }

class ShootPresetEditSheet extends StatefulWidget {
  const ShootPresetEditSheet({
    super.key,
    required this.mode,
    this.initialPreset,
    this.initialParams,
  });

  final ShootPresetEditMode mode;
  final ShootPreset? initialPreset;
  final ShootParams? initialParams;

  static Future<({ShootParams? params, ShootPreset? preset})?> show(
    BuildContext context, {
    required ShootPresetEditMode mode,
    ShootPreset? initialPreset,
    ShootParams? initialParams,
  }) {
    return showModalBottomSheet<({ShootParams? params, ShootPreset? preset})?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ShootPresetEditSheet(
          mode: mode,
          initialPreset: initialPreset,
          initialParams: initialParams,
        ),
      ),
    );
  }

  @override
  State<ShootPresetEditSheet> createState() => _ShootPresetEditSheetState();
}

class _ShootPresetEditSheetState extends State<ShootPresetEditSheet> {
  late final TextEditingController _nameController;
  late ShootParams _params;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final preset = widget.initialPreset;
    _params = widget.initialParams ??
        preset?.params ??
        PresetCatalog.defaultShootParams;
    _nameController = TextEditingController(
      text: preset?.label ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _title {
    return switch (widget.mode) {
      ShootPresetEditMode.create => '新建预设',
      ShootPresetEditMode.edit => '编辑预设',
      ShootPresetEditMode.customize => '自定义参数',
    };
  }

  Future<void> _save({required bool applyOnly}) async {
    final name = _nameController.text.trim();
    if (!applyOnly && name.isEmpty) {
      _showMessage('请输入预设名称');
      return;
    }

    if (widget.mode == ShootPresetEditMode.customize || applyOnly) {
      if (!mounted) return;
      Navigator.pop(context, (params: _params, preset: null));
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ShootPresetRepository.instance;
      if (widget.mode == ShootPresetEditMode.edit &&
          widget.initialPreset != null) {
        final result = await repo.update(
          widget.initialPreset!.id,
          label: name,
          params: _params,
        );
        if (!mounted) return;
        if (result.error != null) {
          _showMessage(result.error!);
          return;
        }
        Navigator.pop(
          context,
          (params: result.preset!.params, preset: result.preset),
        );
      } else {
        final result = await repo.create(label: name, params: _params);
        if (!mounted) return;
        if (result.error != null) {
          _showMessage(result.error!);
          return;
        }
        Navigator.pop(
          context,
          (params: result.preset!.params, preset: result.preset),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isCustomize = widget.mode == ShootPresetEditMode.customize;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(_title, style: AppTextStyles.title),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (!isCustomize) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '预设名称',
                  hintText: '例如：夜景街拍',
                ),
              ),
            ],
            const SizedBox(height: 16),
            ShootParamPresetCards(
              params: _params,
              onChanged: (params) => setState(() => _params = params),
            ),
            const SizedBox(height: 20),
            if (isCustomize)
              FilledButton(
                onPressed: _saving ? null : () => _save(applyOnly: true),
                child: const Text('应用'),
              )
            else ...[
              FilledButton(
                onPressed: _saving ? null : () => _save(applyOnly: false),
                child: Text(_saving ? '保存中…' : '保存'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saving ? null : () => _save(applyOnly: true),
                child: const Text('仅应用，不保存'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
