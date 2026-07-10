import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../data/ip_repository.dart';
import '../../../../shared/widgets/glass/glass.dart';
class IpEditPage extends StatefulWidget {
  const IpEditPage({super.key, this.ipId});

  /// Null means create mode.
  final int? ipId;

  bool get isEditing => ipId != null;

  @override
  State<IpEditPage> createState() => _IpEditPageState();
}

class _IpEditPageState extends State<IpEditPage> {
  final _repo = IpRepository.instance;
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _summaryController = TextEditingController();

  bool _loading = false;
  bool _saving = false;
  String? _loadError;
  int _workType = AppCatalog.ipWorkTypePresets.first.value;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _load();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final result = await _repo.fetchDetail(widget.ipId!);
    if (!mounted) return;

    if (result.ip != null) {
      final ip = result.ip!;
      _titleController.text = ip.title;
      _yearController.text =
          ip.releaseYear > 0 ? '${ip.releaseYear}' : '';
      _summaryController.text = ip.summary;
      _workType = ip.workType;
      _loadError = null;
    } else {
      _loadError = result.error ?? 'IP 不存在';
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnack('请填写标题');
      return;
    }

    final year = int.tryParse(_yearController.text.trim()) ?? 0;

    setState(() => _saving = true);
    if (widget.isEditing) {
      final result = await _repo.update(
        id: widget.ipId!,
        title: title,
        workType: _workType,
        releaseYear: year,
        summary: _summaryController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (result.error != null) {
        _showSnack(result.error!);
        return;
      }
      context.pop();
      context.push(AppRoutes.ip(widget.ipId!));
      return;
    }

    final result = await _repo.create(
      title: title,
      workType: _workType,
      releaseYear: year,
      summary: _summaryController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.error != null) {
      _showSnack(result.error!);
      return;
    }
    if (result.ip != null) {
      context.pop();
      context.push(AppRoutes.ip(result.ip!.id));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: Text(widget.isEditing ? '编辑 IP' : '新建 IP'),
      onBack: () => popOrGoDiscovery(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null && widget.isEditing
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    GlassEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: '加载失败',
                      subtitle: _loadError,
                      actionLabel: '重试',
                      onAction: _load,
                    ),
                  ],
                )
              : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('标题', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'IP 名称'),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text('类型', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _workType,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      for (final preset in AppCatalog.ipWorkTypePresets)
                        DropdownMenuItem(
                          value: preset.value,
                          child: Text(preset.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _workType = value);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text('年份', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '例如 2024'),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text('简介', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _summaryController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'IP 简介…'),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  GlassButton(
                filled: true,
                expand: true,
                    label: widget.isEditing ? '保存' : '创建',
                    onPressed: _save,
                    loading: _saving,
                  ),
                ],
              ),
            ),
    );
  }
}
