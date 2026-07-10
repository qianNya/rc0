import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../data/screenplay_visibility_service.dart';
import '../../../user/data/user_screenplays_repository.dart';
import '../../../../shared/widgets/glass/glass.dart';

/// Shared radio list for screenplay visibility (公开 / 非公开).
class ScreenplayVisibilityOptions extends StatelessWidget {
  const ScreenplayVisibilityOptions({
    super.key,
    required this.value,
    this.onChanged,
    this.privateEnabled = true,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final bool privateEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('选择可见性', style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppDimensions.spacingSm),
        GlassListRow(
          leading: Icon(
            value == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
            color: value == 1 ? AppColors.accent : null,
          ),
          title: '公开',
          subtitle: '公开可见，可出现在作品列表',
          dense: true,
          onTap: onChanged == null ? null : () => onChanged!(1),
        ),
        GlassListRow(
          leading: Icon(
            value == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
            color: value == 0 && privateEnabled
                ? AppColors.accent
                : AppColors.textTertiary,
          ),
          title: '非公开',
          subtitle: '仅服务端存档，可通过 JSON 导出分享',
          dense: true,
          onTap: (!privateEnabled || onChanged == null)
              ? null
              : () => onChanged!(0),
        ),
      ],
    );
  }
}

/// Bottom sheet for editing visibility of a published remote screenplay.
class ScreenplayVisibilitySheet extends StatefulWidget {
  const ScreenplayVisibilitySheet({
    super.key,
    required this.screenplay,
    required this.userId,
  });

  final Screenplay screenplay;
  final int userId;

  static Future<void> show(
    BuildContext context, {
    required Screenplay screenplay,
    required int userId,
  }) {
    return showGlassSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
      ),
      child: ScreenplayVisibilitySheet(
        screenplay: screenplay,
        userId: userId,
      ),
    );
  }

  @override
  State<ScreenplayVisibilitySheet> createState() =>
      _ScreenplayVisibilitySheetState();
}

class _ScreenplayVisibilitySheetState extends State<ScreenplayVisibilitySheet> {
  late int _visibility;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _visibility = widget.screenplay.visibility ?? 0;
  }

  Future<void> _save() async {
    final remoteId = widget.screenplay.remoteScreenplayId;
    if (remoteId == null || _saving) return;
    if (_visibility == widget.screenplay.visibility) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    final error = await ScreenplayVisibilityService.instance.updateVisibility(
      remoteId,
      _visibility,
    );
    if (!mounted) return;

    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    UserScreenplaysRepository.instance.updateItemVisibility(
      widget.userId,
      remoteId,
      _visibility,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_visibility == 1 ? '已设为公开' : '已设为非公开'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('公开设置', style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          widget.screenplay.title,
          style: AppTextStyles.bodySecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        ScreenplayVisibilityOptions(
          value: _visibility,
          onChanged: (v) => setState(() => _visibility = v),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        GlassButton(
          label: '保存',
          filled: true,
          expand: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
