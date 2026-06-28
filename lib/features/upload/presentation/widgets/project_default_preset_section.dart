import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/shoot_preset_repository.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../../../screenplay/domain/shoot_preset.dart';
import '../utils/shoot_preset_navigation.dart';
import 'preset_marketplace_widgets.dart';

/// Default shoot params picker using preset library cards (recent + official).
class ProjectDefaultPresetSection extends StatefulWidget {
  const ProjectDefaultPresetSection({
    super.key,
    required this.params,
    required this.onChanged,
    this.compact = false,
  });

  final ShootParams params;
  final ValueChanged<ShootParams> onChanged;
  final bool compact;

  @override
  State<ProjectDefaultPresetSection> createState() =>
      _ProjectDefaultPresetSectionState();
}

class _ProjectDefaultPresetSectionState extends State<ProjectDefaultPresetSection> {
  final _repo = ShootPresetRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    if (!_repo.isLoaded) {
      _repo.load();
    }
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => scheduleSetState(this);

  void _applyPreset(ShootPreset preset) {
    _repo.recordUsage(preset);
    widget.onChanged(preset.params);
  }

  Future<void> _openPresetLibrary() async {
    final picked = await openShootPresetPicker(context, scope: 'screenplay');
    if (picked != null) widget.onChanged(picked);
  }

  bool _isSelected(ShootPreset preset) => preset.params == widget.params;

  @override
  Widget build(BuildContext context) {
    if (!_repo.isLoaded && _repo.allPresets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final recent = _repo.recentPresets.isNotEmpty
        ? _repo.recentPresets.take(6).toList()
        : _repo.builtinPresets.take(4).toList();
    final official = _repo.builtinPresets.take(8).toList();
    final matched = _repo.findByParams(widget.params);

    final recentHeight = widget.compact ? 142.0 : 168.0;
    final officialHeight = widget.compact ? 186.0 : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (matched != null || widget.params.hasAnyValue) ...[
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.compact ? 6 : AppDimensions.spacingSm,
            ),
            child: Text(
              matched != null
                  ? '当前：${matched.label}'
                  : '当前：${ShootPreset.subtitleFromParams(widget.params)}',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          ),
        ],
        if (recent.isNotEmpty) ...[
          PresetSectionHeader(
            title: '最近使用',
            leadingIcon: Icons.star_rounded,
            compact: widget.compact,
          ),
          SizedBox(
            height: recentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (_, index) {
                final preset = recent[index];
                return PresetRecentCard(
                  preset: preset,
                  selected: _isSelected(preset),
                  onTap: () => _applyPreset(preset),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
        PresetSectionHeader(
          title: '官方预设',
          trailingLabel: '全部',
          onTrailingTap: _openPresetLibrary,
          compact: widget.compact,
        ),
        SizedBox(
          height: officialHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: official.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.spacingSm),
            itemBuilder: (_, index) {
              final preset = official[index];
              return PresetOfficialCard(
                preset: preset,
                compact: true,
                selected: _isSelected(preset),
                onTap: () => _applyPreset(preset),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _openPresetLibrary,
            child: const Text('浏览预设库'),
          ),
        ),
        if (_repo.lastError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _repo.lastError!,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 11,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
