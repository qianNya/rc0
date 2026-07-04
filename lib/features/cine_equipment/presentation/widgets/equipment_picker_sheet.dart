import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/equipment_repository.dart';
import '../../data/equipment_setup_mapper.dart';
import '../../domain/cine_camera_setup.dart';

/// Quick picker for saved camera setups.
class EquipmentPickerSheet extends StatefulWidget {
  const EquipmentPickerSheet({super.key});

  static Future<CineCameraSetup?> show(BuildContext context) {
    return showGlassSheet<CineCameraSetup>(
      context,
      child: const EquipmentPickerSheet(),
    );
  }

  @override
  State<EquipmentPickerSheet> createState() => _EquipmentPickerSheetState();
}

class _EquipmentPickerSheetState extends State<EquipmentPickerSheet> {
  final _repo = EquipmentRepository.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _repo.addListener(_onRepo);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final setups = _repo.allSetups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('选择摄影机组合', style: AppTextStyles.title),
        const SizedBox(height: AppDimensions.spacingMd),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: setups.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spacingSm),
              itemBuilder: (context, index) {
                final setup = setups[index];
                final summary = EquipmentSetupMapper.displaySummary(setup);
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Text(
                    setup.title.isNotEmpty ? setup.title : summary,
                  ),
                  subtitle: Text(summary),
                  onTap: () => Navigator.of(context).pop(setup),
                );
              },
            ),
          ),
      ],
    );
  }
}
