import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../data/gear_cabinet_repository.dart';
import '../../domain/gear_cabinet.dart';
import '../../domain/gear_device.dart';
import '../../domain/gear_device_status.dart';
import '../../domain/gear_shelf.dart';
import '../theme/gear_cabinet_colors.dart';
import '../widgets/gear_cabinet_app_bar.dart';
import '../widgets/gear_cabinet_background.dart';

/// Full-screen device detail — zoom level "Detail".
class GearDeviceDetailPage extends StatefulWidget {
  const GearDeviceDetailPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<GearDeviceDetailPage> createState() => _GearDeviceDetailPageState();
}

class _GearDeviceDetailPageState extends State<GearDeviceDetailPage> {
  final _repo = GearCabinetRepository.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final location = _repo.locateDevice(widget.deviceId);
    final device = location != null
        ? _repo.deviceById(widget.deviceId)
        : null;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GearCabinetColors.background,
      ),
      child: GearCabinetBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: GearCabinetAppBar(
            showBack: true,
            onBack: () => popOrGoHome(context),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GearCabinetColors.accent,
                  ),
                )
              : device == null || location == null
                  ? EmptyStateView(
                      icon: Icons.devices_outlined,
                      title: '设备未找到',
                      subtitle: '请返回设备库',
                      actionLabel: '返回',
                      onAction: () => popOrGoHome(context),
                    )
                  : _buildContent(context, device, location),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GearDevice device,
    ({GearRoom room, GearCabinet cabinet, GearShelf? shelf}) location,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: GearCabinetAppBar().preferredSize.height +
                MediaQuery.paddingOf(context).top,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedOpacity(
                  opacity: 1,
                  duration: AppMotion.slow,
                  child: Hero(
                    tag: 'gear-device-${device.id}',
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF1E2530),
                              GearCabinetColors.shelfInner,
                            ],
                          ),
                          border: Border.all(
                            color: GearCabinetColors.borderWood
                                .withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GearCabinetColors.accent
                                  .withValues(alpha: 0.12),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            device.icon ?? Icons.devices_outlined,
                            size: 96,
                            color: GearCabinetColors.textPrimary
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: GearCabinetColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    _StatusChip(status: device.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  device.brand,
                  style: const TextStyle(
                    fontSize: 15,
                    color: GearCabinetColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  runSpacing: AppDimensions.spacingSm,
                  children: device.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              GearCabinetColors.accentGlow,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            color: GearCabinetColors.accent,
                          ),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _InfoSection(
                  title: '位置',
                  rows: {
                    '房间': location.room.name,
                    '柜子': location.cabinet.name,
                    if (location.shelf != null) '格层': location.shelf!.label,
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _InfoSection(title: '技术参数', rows: device.specs),
                if (device.notes != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  _InfoSection(
                    title: '备注',
                    rows: {'': device.notes!},
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GearDeviceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: status.color.withValues(alpha: 0.15),
        border: Border.all(color: status.color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.rows});

  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: GearCabinetColors.shelfInner.withValues(alpha: 0.6),
        border: Border.all(
          color: GearCabinetColors.borderWood.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: GearCabinetColors.nameplateGoldDim,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.key.isNotEmpty)
                      SizedBox(
                        width: 72,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: GearCabinetColors.textTertiary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: GearCabinetColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
