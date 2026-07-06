import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/gear_cabinet_repository.dart';
import '../../domain/gear_device.dart';
import '../theme/gear_cabinet_colors.dart';

Future<GearDevice?> showGearSearchSheet(BuildContext context) {
  return showGlassScrollSheet<GearDevice>(
    context,
    maxHeightFraction: 0.75,
    padding: const EdgeInsets.fromLTRB(
      AppDimensions.spacingMd,
      0,
      AppDimensions.spacingMd,
      AppDimensions.spacingMd,
    ),
    builder: (context, maxHeight) => _GearSearchBody(maxHeight: maxHeight),
  );
}

class _GearSearchBody extends StatefulWidget {
  const _GearSearchBody({required this.maxHeight});

  final double maxHeight;

  @override
  State<_GearSearchBody> createState() => _GearSearchBodyState();
}

class _GearSearchBodyState extends State<_GearSearchBody> {
  final _controller = TextEditingController();
  List<GearDevice> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = GearCabinetRepository.instance.searchDevices(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: GearCabinetColors.textPrimary),
            decoration: InputDecoration(
              hintText: '搜索设备名称、品牌…',
              hintStyle: const TextStyle(color: GearCabinetColors.textTertiary),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: GearCabinetColors.textSecondary,
              ),
              filled: true,
              fillColor: GearCabinetColors.shelfInner,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.floatingBarRadius),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _controller.text.isEmpty ? '输入关键词搜索' : '无匹配设备',
                      style: const TextStyle(
                        color: GearCabinetColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => Divider(
                      color: GearCabinetColors.borderWood.withValues(alpha: 0.3),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final device = _results[index];
                      return ListTile(
                        leading: Icon(
                          device.icon ?? Icons.devices_outlined,
                          color: GearCabinetColors.accent,
                        ),
                        title: Text(
                          device.name,
                          style: const TextStyle(
                            color: GearCabinetColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          device.brand,
                          style: const TextStyle(
                            color: GearCabinetColors.textSecondary,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(device),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
