import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../data/gear_cabinet_repository.dart';
import '../../domain/gear_cabinet.dart';
import '../../domain/gear_device.dart';
import '../../domain/gear_room_type.dart';
import '../../domain/gear_zoom_level.dart';
import '../theme/gear_cabinet_colors.dart';
import '../widgets/gear_cabinet_app_bar.dart';
import '../widgets/gear_cabinet_background.dart';
import '../widgets/gear_cabinet_focus_view.dart';
import '../widgets/gear_cabinet_overview.dart';
import '../widgets/gear_cabinet_zoom_fab.dart';
import '../widgets/gear_room_tabs.dart';
import '../widgets/gear_search_sheet.dart';

/// Main gear cabinet page — Room → Cabinet → Shelf → Device hierarchy.
class GearCabinetPage extends StatefulWidget {
  const GearCabinetPage({super.key});

  @override
  State<GearCabinetPage> createState() => _GearCabinetPageState();
}

class _GearCabinetPageState extends State<GearCabinetPage>
    with TickerProviderStateMixin {
  final _repo = GearCabinetRepository.instance;

  GearRoomType _roomType = GearRoomType.lighting;
  GearZoomLevel _zoomLevel = GearZoomLevel.overview;
  String? _focusedCabinetId;
  double _pinchScale = 1.0;
  bool _loading = true;
  bool _editLayout = false;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _load();
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

  GearRoom? get _currentRoom => _repo.roomByType(_roomType);

  GearCabinet? get _focusedCabinet {
    final id = _focusedCabinetId;
    if (id == null) return null;
    return _repo.cabinetById(id);
  }

  void _selectRoom(GearRoomType type) {
    setState(() {
      _roomType = type;
      _zoomLevel = GearZoomLevel.overview;
      _focusedCabinetId = null;
      _pinchScale = 1.0;
    });
  }

  void _focusCabinet(GearCabinet cabinet) {
    setState(() {
      _focusedCabinetId = cabinet.id;
      _zoomLevel = GearZoomLevel.focus;
      _pinchScale = 1.0;
    });
  }

  void _toggleZoom() {
    setState(() {
      if (_zoomLevel == GearZoomLevel.overview) {
        final room = _currentRoom;
        if (room != null && room.cabinets.isNotEmpty) {
          _focusedCabinetId = room.cabinets.first.id;
          _zoomLevel = GearZoomLevel.focus;
        }
      } else {
        _zoomLevel = GearZoomLevel.overview;
        _focusedCabinetId = null;
        _pinchScale = 1.0;
      }
    });
  }

  void _openDevice(GearDevice device) {
    context.push(AppRoutes.gearDeviceDetailPath(device.id));
  }

  Future<void> _openSearch() async {
    final device = await showGearSearchSheet(context);
    if (device != null && mounted) {
      _openDevice(device);
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — 即将推出')),
    );
  }

  Future<void> _saveLayout() async {
    final error = await _repo.saveLayout();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('布局已保存')));
  }

  void _toggleEditLayout() {
    setState(() => _editLayout = !_editLayout);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GearCabinetColors.background,
        colorScheme: const ColorScheme.dark(
          primary: GearCabinetColors.accent,
          surface: GearCabinetColors.shelfInner,
        ),
      ),
      child: GearCabinetBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: GearCabinetAppBar(
            onSearch: _openSearch,
            onFilter: () => _showComingSoon('筛选'),
            onAdd: () => _showComingSoon('添加设备'),
            onSaveLayout: _saveLayout,
            layoutDirty: _repo.layoutDirty,
            savingLayout: _repo.savingLayout,
            editMode: _editLayout,
            onToggleEdit: _toggleEditLayout,
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GearCabinetColors.accent,
                  ),
                )
              : _repo.error != null
                  ? EmptyStateView(
                      icon: Icons.inventory_2_outlined,
                      title: '加载失败',
                      subtitle: _repo.error,
                      actionLabel: '重试',
                      onAction: () {
                        setState(() => _loading = true);
                        _repo.refresh().then((_) {
                          if (mounted) setState(() => _loading = false);
                        });
                      },
                    )
                  : _buildBody(),
          floatingActionButton: _currentRoom != null &&
                  _currentRoom!.cabinets.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.floatingBottomClearance,
                  ),
                  child: GearCabinetZoomFab(
                    zoomLevel: _zoomLevel,
                    onToggle: _toggleZoom,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody() {
    final room = _currentRoom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: GearCabinetAppBar().preferredSize.height +
              MediaQuery.paddingOf(context).top,
        ),
        GearRoomTabs(
          selected: _roomType,
          onChanged: _selectRoom,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(child: _buildRoomContent(room)),
      ],
    );
  }

  Widget _buildRoomContent(GearRoom? room) {
    if (room == null || room.cabinets.isEmpty) {
      return const EmptyStateView(
        icon: Icons.inventory_2_outlined,
        title: '暂无柜子',
        subtitle: '添加第一个设备柜开始管理',
      );
    }

    return FadeSlideIndexedStack(
      index: _roomType.index,
      children: GearRoomType.values
          .map((type) {
            final r = _repo.roomByType(type);
            if (r == null || r.cabinets.isEmpty) {
              return const EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: '暂无设备',
                subtitle: '此房间还没有柜子',
              );
            }
            return _buildZoomableCabinetArea(r);
          })
          .toList(growable: false),
    );
  }

  Widget _buildZoomableCabinetArea(GearRoom room) {
    return GestureDetector(
      onScaleStart: (_) => _pinchScale = 1.0,
      onScaleUpdate: (details) {
        if (details.scale == 1.0) return;
        setState(() {
          _pinchScale = details.scale.clamp(0.85, 1.2);
          if (details.scale > 1.08 && _zoomLevel == GearZoomLevel.overview) {
            final cabinet = _focusedCabinet ?? room.cabinets.first;
            _focusedCabinetId = cabinet.id;
            _zoomLevel = GearZoomLevel.focus;
          } else if (details.scale < 0.92 &&
              _zoomLevel == GearZoomLevel.focus) {
            _zoomLevel = GearZoomLevel.overview;
            _focusedCabinetId = null;
          }
        });
      },
      onScaleEnd: (_) {
        setState(() => _pinchScale = 1.0);
      },
      child: AnimatedSwitcher(
        duration: AppMotion.slow,
        switchInCurve: AppMotion.standard,
        switchOutCurve: AppMotion.standard,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _zoomLevel == GearZoomLevel.overview
            ? KeyedSubtree(
                key: const ValueKey('overview'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.spacingMd,
                        AppDimensions.spacingSm,
                        AppDimensions.spacingMd,
                        0,
                      ),
                      child: Text(
                        '${room.name} · ${room.deviceCount} 件设备',
                        style: const TextStyle(
                          fontSize: 13,
                          color: GearCabinetColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GearCabinetOverview(
                        cabinets: room.cabinets,
                        onCabinetTap: _focusCabinet,
                        onAddCabinet: () => _showComingSoon('添加柜子'),
                        editMode: _editLayout,
                        onReorder: (oldIndex, newIndex) {
                          _repo.reorderCabinets(_roomType, oldIndex, newIndex);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : KeyedSubtree(
                key: ValueKey('focus-$_focusedCabinetId'),
                child: _focusedCabinet != null
                    ? GearCabinetFocusView(
                        cabinet: _focusedCabinet!,
                        onDeviceTap: _openDevice,
                        scale: _pinchScale,
                        editMode: _editLayout,
                        onDeviceReorder: (shelfId, oldIndex, newIndex) {
                          _repo.reorderDevices(
                            cabinetId: _focusedCabinet!.id,
                            shelfId: shelfId,
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
      ),
    );
  }
}
