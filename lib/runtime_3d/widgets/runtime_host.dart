import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rc0_unity_widget/rc0_unity_widget.dart';

import '../../features/action/presentation/models/action_model_source.dart';
import '../../features/lighting/data/lighting_scheme_mapper.dart';
import '../../features/lighting/domain/lighting_scheme.dart';
import '../contracts/pose_contract.dart';
import '../core/runtime_event.dart';
import '../core/runtime_session.dart';
import 'runtime_controller.dart';
import 'runtime_preview_fallback.dart';

/// Single 3D viewport entry — embeds Unity and syncs module state.
class RuntimeHost extends StatefulWidget {
  const RuntimeHost({
    super.key,
    required this.mode,
    this.controller,
    this.model,
    this.lightingScheme,
    this.selectedLightId,
    this.planView = false,
    this.autoRotate = false,
    this.poseMode = ModelPoseMode.standing,
    this.selectedAnimationName,
    this.onAnimationsChanged,
    this.onLightingEvent,
    this.backgroundColor = const Color(0xFF121018),
    this.immersive = false,
  });

  final RuntimeMode mode;
  final RuntimeController? controller;
  final ActionModelSource? model;
  final LightingScheme? lightingScheme;
  final String? selectedLightId;
  final bool planView;
  final bool autoRotate;
  final ModelPoseMode poseMode;
  final String? selectedAnimationName;
  final ValueChanged<List<String>>? onAnimationsChanged;
  final ValueChanged<LightingRuntimeEvent>? onLightingEvent;
  final Color backgroundColor;
  final bool immersive;

  @override
  State<RuntimeHost> createState() => _RuntimeHostState();
}

class _RuntimeHostState extends State<RuntimeHost> {
  late final String _sessionId;
  RuntimeSession? _session;
  StreamSubscription<RuntimeEvent>? _eventSub;
  Object? _syncToken;
  bool? _unityLinked;
  bool _checkingUnity = true;

  @override
  void initState() {
    super.initState();
    _sessionId = 'rc0-${widget.mode.name}-${identityHashCode(this)}';
    _session = RuntimeSession(sessionId: _sessionId);
    widget.controller?.attachSession(_session!);
    _eventSub = _session!.events.listen(_onRuntimeEvent);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final linked = await _session!.bridge.isUnityAvailable;
    if (!mounted) return;
    setState(() {
      _unityLinked = linked;
      _checkingUnity = false;
    });
    if (linked) {
      await _syncAll();
    } else {
      widget.onAnimationsChanged?.call(const []);
    }
  }

  @override
  void didUpdateWidget(covariant RuntimeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_unityLinked != true) return;

    final token = Object.hash(
      widget.mode,
      widget.model?.name,
      widget.lightingScheme?.id,
      widget.lightingScheme?.lights,
      widget.planView,
      widget.autoRotate,
      widget.poseMode,
      widget.selectedAnimationName,
      widget.selectedLightId,
    );
    if (token != _syncToken) {
      unawaited(_syncAll());
    }
  }

  @override
  void dispose() {
    widget.controller?.detachSession();
    _eventSub?.cancel();
    _session?.dispose();
    super.dispose();
  }

  Future<void> _syncAll() async {
    final session = _session;
    if (session == null || _unityLinked != true) return;

    _syncToken = Object.hash(
      widget.mode,
      widget.model?.name,
      widget.lightingScheme?.id,
      widget.lightingScheme?.lights,
      widget.planView,
      widget.autoRotate,
      widget.poseMode,
      widget.selectedAnimationName,
      widget.selectedLightId,
    );

    final modeName = widget.mode == RuntimeMode.lightingEditor
        ? 'lightingEditor'
        : 'characterPreview';
    await session.initializeScene(mode: modeName);
    await session.character.load(widget.model);
    await session.camera.setPlanView(widget.planView);
    await session.camera.setAutoRotate(widget.autoRotate);
    await session.pose.apply(widget.poseMode);

    if (widget.selectedAnimationName != null) {
      await session.animation.play(widget.selectedAnimationName);
    } else {
      await session.animation.stop();
    }

    final scheme = widget.lightingScheme;
    if (scheme != null) {
      await session.lighting.applyRig(LightingSchemeMapper.rigToJson(scheme));
      final selected = widget.selectedLightId;
      if (selected != null) {
        await session.lighting.selectLight(selected);
      }
    }
  }

  void _onRuntimeEvent(RuntimeEvent event) {
    if (event.module == 'character' && event.eventName == 'ready') {
      final names = event.payload['animationNames'];
      if (names is List) {
        widget.onAnimationsChanged?.call([
          for (final n in names) '$n',
        ]);
      }
      return;
    }

    final lightingEvent = parseLightingEvent(event);
    if (lightingEvent != null) {
      widget.onLightingEvent?.call(lightingEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUnity) {
      return ColoredBox(
        color: widget.backgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final child = _unityLinked == true
        ? Rc0UnityView(
            sessionId: _sessionId,
            placeholder: ColoredBox(color: widget.backgroundColor),
          )
        : RuntimePreviewFallback(
            model: widget.model,
            poseMode: widget.poseMode,
            backgroundColor: widget.backgroundColor,
            compact: widget.immersive,
          );

    if (widget.immersive) {
      return ColoredBox(
        color: widget.backgroundColor,
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: ColoredBox(
        color: widget.backgroundColor,
        child: child,
      ),
    );
  }
}
