import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart' as model_viewer;
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../models/action_model_source.dart';

bool get isRealModelViewerRealtimeSupported => true;

bool get _usesModelViewerRenderer =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid);

bool get _usesFlutterGlRenderer => !_usesModelViewerRenderer;

enum ModelPoseMode {
  standing,
  sitting,
  walking,
  running,
  jumping,
  crouching,
  kneeling,
  lying,
  armsUp,
  waving,
}

extension ModelPoseModeLabel on ModelPoseMode {
  String get label {
    switch (this) {
      case ModelPoseMode.standing:
        return '站立';
      case ModelPoseMode.sitting:
        return '坐姿';
      case ModelPoseMode.walking:
        return '走路';
      case ModelPoseMode.running:
        return '跑步';
      case ModelPoseMode.jumping:
        return '跳跃';
      case ModelPoseMode.crouching:
        return '蹲下';
      case ModelPoseMode.kneeling:
        return '跪姿';
      case ModelPoseMode.lying:
        return '躺下';
      case ModelPoseMode.armsUp:
        return '举手';
      case ModelPoseMode.waving:
        return '挥手';
    }
  }
}

enum _SkeletonBoneRole {
  hips,
  spine,
  neck,
  head,
  leftShoulder,
  rightShoulder,
  leftUpperArm,
  rightUpperArm,
  leftLowerArm,
  rightLowerArm,
  leftHand,
  rightHand,
  leftUpperLeg,
  rightUpperLeg,
  leftLowerLeg,
  rightLowerLeg,
  leftFoot,
  rightFoot,
}

double _deg(double value) => value * math.pi / 180;

_SkeletonBoneRole? _boneRoleForName(String rawName) {
  final name = rawName.toLowerCase().replaceAll(RegExp(r'[\s_\-\.]'), '');
  if (name.isEmpty) return null;

  final isLeft = _containsAny(name, const ['left', '左']);
  final isRight = _containsAny(name, const ['right', '右']);

  if (_containsAny(name, const [
    'hips',
    'pelvis',
    'root',
    'center',
    'centre',
    'センター',
    '下半身',
    '腰',
  ])) {
    return _SkeletonBoneRole.hips;
  }

  if (_containsAny(name, const ['spine', 'chest', 'upperchest', '上半身', '胸'])) {
    return _SkeletonBoneRole.spine;
  }

  if (_containsAny(name, const ['neck', '首', 'くび'])) {
    return _SkeletonBoneRole.neck;
  }

  if (_containsAny(name, const ['head', '頭', '头'])) {
    return _SkeletonBoneRole.head;
  }

  if (_containsAny(name, const ['shoulder', 'clavicle', '肩'])) {
    if (isLeft) return _SkeletonBoneRole.leftShoulder;
    if (isRight) return _SkeletonBoneRole.rightShoulder;
  }

  if (_containsAny(name, const [
    'forearm',
    'lowerarm',
    'elbow',
    'ひじ',
    '肘',
    '前腕',
  ])) {
    if (isLeft) return _SkeletonBoneRole.leftLowerArm;
    if (isRight) return _SkeletonBoneRole.rightLowerArm;
  }

  if (_containsAny(name, const ['upperarm', 'arm', '腕'])) {
    if (isLeft) return _SkeletonBoneRole.leftUpperArm;
    if (isRight) return _SkeletonBoneRole.rightUpperArm;
  }

  if (_containsAny(name, const ['hand', 'wrist', '手首', '手'])) {
    if (isLeft) return _SkeletonBoneRole.leftHand;
    if (isRight) return _SkeletonBoneRole.rightHand;
  }

  if (_containsAny(name, const ['upleg', 'upperleg', 'thigh', '太もも', '腿'])) {
    if (isLeft) return _SkeletonBoneRole.leftUpperLeg;
    if (isRight) return _SkeletonBoneRole.rightUpperLeg;
  }

  if (_containsAny(name, const [
    'leg',
    'lowerleg',
    'calf',
    'shin',
    'knee',
    'ひざ',
    '膝',
  ])) {
    if (isLeft) return _SkeletonBoneRole.leftLowerLeg;
    if (isRight) return _SkeletonBoneRole.rightLowerLeg;
  }

  if (_containsAny(name, const ['foot', 'ankle', '足首', '足', '脚'])) {
    if (isLeft) return _SkeletonBoneRole.leftFoot;
    if (isRight) return _SkeletonBoneRole.rightFoot;
  }

  return null;
}

bool _containsAny(String name, List<String> tokens) {
  return tokens.any(name.contains);
}

({double x, double y, double z})? _poseOffset(
  _SkeletonBoneRole role,
  ModelPoseMode poseMode,
) {
  switch (poseMode) {
    case ModelPoseMode.standing:
      return null;
    case ModelPoseMode.sitting:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-8, 0, 0),
        _SkeletonBoneRole.spine: (8, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-72, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (-72, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (82, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (82, 0, 0),
        _SkeletonBoneRole.leftFoot: (-12, 0, 0),
        _SkeletonBoneRole.rightFoot: (-12, 0, 0),
      });
    case ModelPoseMode.walking:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-4, 0, 0),
        _SkeletonBoneRole.spine: (5, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-32, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (28, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (38, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (-12, 0, 0),
        _SkeletonBoneRole.leftUpperArm: (28, 0, -8),
        _SkeletonBoneRole.rightUpperArm: (-28, 0, 8),
        _SkeletonBoneRole.leftLowerArm: (-16, 0, 0),
        _SkeletonBoneRole.rightLowerArm: (16, 0, 0),
      });
    case ModelPoseMode.running:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-10, 0, 0),
        _SkeletonBoneRole.spine: (14, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-58, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (44, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (72, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (-26, 0, 0),
        _SkeletonBoneRole.leftUpperArm: (48, 0, -12),
        _SkeletonBoneRole.rightUpperArm: (-48, 0, 12),
        _SkeletonBoneRole.leftLowerArm: (-68, 0, 0),
        _SkeletonBoneRole.rightLowerArm: (68, 0, 0),
      });
    case ModelPoseMode.jumping:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-6, 0, 0),
        _SkeletonBoneRole.spine: (12, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-28, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (-28, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (36, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (36, 0, 0),
        _SkeletonBoneRole.leftFoot: (-16, 0, 0),
        _SkeletonBoneRole.rightFoot: (-16, 0, 0),
        _SkeletonBoneRole.leftUpperArm: (-128, 0, -22),
        _SkeletonBoneRole.rightUpperArm: (-128, 0, 22),
        _SkeletonBoneRole.leftLowerArm: (-18, 0, 0),
        _SkeletonBoneRole.rightLowerArm: (-18, 0, 0),
      });
    case ModelPoseMode.crouching:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-18, 0, 0),
        _SkeletonBoneRole.spine: (20, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-96, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (-96, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (120, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (120, 0, 0),
        _SkeletonBoneRole.leftFoot: (-20, 0, 0),
        _SkeletonBoneRole.rightFoot: (-20, 0, 0),
        _SkeletonBoneRole.leftUpperArm: (-22, 0, -12),
        _SkeletonBoneRole.rightUpperArm: (-22, 0, 12),
      });
    case ModelPoseMode.kneeling:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (-12, 0, 0),
        _SkeletonBoneRole.spine: (12, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (-88, 0, 0),
        _SkeletonBoneRole.leftLowerLeg: (112, 0, 0),
        _SkeletonBoneRole.rightUpperLeg: (-26, 0, 0),
        _SkeletonBoneRole.rightLowerLeg: (38, 0, 0),
        _SkeletonBoneRole.leftFoot: (-16, 0, 0),
        _SkeletonBoneRole.rightFoot: (-8, 0, 0),
      });
    case ModelPoseMode.lying:
      return _poseMap(role, const {
        _SkeletonBoneRole.hips: (86, 0, 0),
        _SkeletonBoneRole.spine: (-6, 0, 0),
        _SkeletonBoneRole.neck: (-8, 0, 0),
        _SkeletonBoneRole.leftUpperLeg: (4, 0, 6),
        _SkeletonBoneRole.rightUpperLeg: (4, 0, -6),
        _SkeletonBoneRole.leftUpperArm: (8, 0, -18),
        _SkeletonBoneRole.rightUpperArm: (8, 0, 18),
      });
    case ModelPoseMode.armsUp:
      return _poseMap(role, const {
        _SkeletonBoneRole.spine: (6, 0, 0),
        _SkeletonBoneRole.leftShoulder: (-12, 0, -10),
        _SkeletonBoneRole.rightShoulder: (-12, 0, 10),
        _SkeletonBoneRole.leftUpperArm: (-132, 0, -18),
        _SkeletonBoneRole.rightUpperArm: (-132, 0, 18),
        _SkeletonBoneRole.leftLowerArm: (-8, 0, 0),
        _SkeletonBoneRole.rightLowerArm: (-8, 0, 0),
      });
    case ModelPoseMode.waving:
      return _poseMap(role, const {
        _SkeletonBoneRole.spine: (5, 0, 0),
        _SkeletonBoneRole.head: (0, -10, 0),
        _SkeletonBoneRole.rightShoulder: (-12, 0, 10),
        _SkeletonBoneRole.rightUpperArm: (-118, 0, 34),
        _SkeletonBoneRole.rightLowerArm: (-62, 0, -18),
        _SkeletonBoneRole.rightHand: (0, 0, 18),
        _SkeletonBoneRole.leftUpperArm: (8, 0, -12),
      });
  }
}

({double x, double y, double z})? _poseMap(
  _SkeletonBoneRole role,
  Map<_SkeletonBoneRole, (double, double, double)> values,
) {
  final offset = values[role];
  if (offset == null) return null;
  return (x: _deg(offset.$1), y: _deg(offset.$2), z: _deg(offset.$3));
}

List<double> _quaternionFromEuler(({double x, double y, double z}) euler) {
  final cx = math.cos(euler.x / 2);
  final sx = math.sin(euler.x / 2);
  final cy = math.cos(euler.y / 2);
  final sy = math.sin(euler.y / 2);
  final cz = math.cos(euler.z / 2);
  final sz = math.sin(euler.z / 2);

  return [
    sx * cy * cz + cx * sy * sz,
    cx * sy * cz - sx * cy * sz,
    cx * cy * sz + sx * sy * cz,
    cx * cy * cz - sx * sy * sz,
  ];
}

({double x, double y, double z}) _eulerFromQuaternion(
  ({double x, double y, double z, double w}) q,
) {
  final sinX = 2 * (q.w * q.x + q.y * q.z);
  final cosX = 1 - 2 * (q.x * q.x + q.y * q.y);
  final x = math.atan2(sinX, cosX);

  final sinY = (2 * (q.w * q.y - q.z * q.x)).clamp(-1.0, 1.0).toDouble();
  final y = math.asin(sinY);

  final sinZ = 2 * (q.w * q.z + q.x * q.y);
  final cosZ = 1 - 2 * (q.y * q.y + q.z * q.z);
  final z = math.atan2(sinZ, cosZ);

  return (x: x, y: y, z: z);
}

class RealModelViewerController {
  VoidCallback? _resetCamera;
  void Function(bool)? _setAutoRotate;

  void _attach({
    required VoidCallback resetCamera,
    required void Function(bool) setAutoRotate,
  }) {
    _resetCamera = resetCamera;
    _setAutoRotate = setAutoRotate;
  }

  void _detach() {
    _resetCamera = null;
    _setAutoRotate = null;
  }

  void resetCamera() => _resetCamera?.call();

  void setAutoRotate(bool enabled) => _setAutoRotate?.call(enabled);
}

class RealModelViewer extends StatefulWidget {
  const RealModelViewer({
    super.key,
    required this.source,
    required this.autoRotate,
    required this.poseMode,
    this.selectedAnimationName,
    this.onAnimationsChanged,
    this.controller,
  });

  final ActionModelSource? source;
  final bool autoRotate;
  final ModelPoseMode poseMode;
  final String? selectedAnimationName;
  final ValueChanged<List<String>>? onAnimationsChanged;
  final RealModelViewerController? controller;

  @override
  State<RealModelViewer> createState() => _RealModelViewerState();
}

class _RealModelViewerState extends State<RealModelViewer>
    with SingleTickerProviderStateMixin {
  final GlobalKey<three_jsm.DomLikeListenableState> _controlsKey =
      GlobalKey<three_jsm.DomLikeListenableState>();

  FlutterGlPlugin? _glPlugin;
  three.WebGLRenderer? _renderer;
  dynamic _sourceTexture;

  three.Scene? _scene;
  three.PerspectiveCamera? _camera;
  three_jsm.OrbitControls? _controls;
  three.Object3D? _modelRoot;
  three.AnimationMixer? _mixer;
  List<three.AnimationClip> _animations = const [];
  final Map<three.Object3D, three.Euler> _baseBoneRotations = {};
  final three.Clock _clock = three.Clock();

  double _width = 0;
  double _height = 0;
  double _dpr = 1;
  bool _glReady = false;
  bool _initializingGl = false;
  bool _sceneReady = false;
  bool _loadingModel = false;
  String? _glError;
  String? _error;
  Ticker? _ticker;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(
      resetCamera: _resetCamera,
      setAutoRotate: _setAutoRotate,
    );
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(covariant RealModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(
        resetCamera: _resetCamera,
        setAutoRotate: _setAutoRotate,
      );
    }
    if (widget.source != oldWidget.source) {
      if (widget.source?.canRender != true) {
        _glError = null;
        _error = null;
        widget.onAnimationsChanged?.call(const []);
      }
      unawaited(_loadModel(widget.source));
    }
    if (widget.selectedAnimationName != oldWidget.selectedAnimationName) {
      _playAnimation(widget.selectedAnimationName);
    }
    if (widget.poseMode != oldWidget.poseMode) {
      _applyPose(widget.poseMode);
    }
    _setAutoRotate(widget.autoRotate);
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.dispose();
    widget.controller?._detach();
    _glPlugin?.dispose();
    super.dispose();
  }

  void _setAutoRotate(bool enabled) {
    final controls = _controls;
    if (controls == null) return;
    controls.autoRotate = enabled;
    controls.autoRotateSpeed = 1.6;
  }

  void _resetCamera() {
    final camera = _camera;
    final controls = _controls;
    final modelRoot = _modelRoot;
    if (camera == null || controls == null || modelRoot == null) return;
    _frameCamera(modelRoot);
    controls.update();
  }

  Future<void> _ensureGl(double width, double height) async {
    if (_glReady ||
        _initializingGl ||
        _glError != null ||
        widget.source?.canRender != true ||
        width <= 0 ||
        height <= 0) {
      return;
    }

    _initializingGl = true;
    _width = width;
    _height = height;
    _dpr = _renderPixelRatio(context);

    if (!_usesFlutterGlRenderer) {
      _initializingGl = false;
      return;
    }

    final plugin = FlutterGlPlugin();
    try {
      await plugin.initialize(
        options: {
          'antialias': true,
          'alpha': false,
          'width': width.toInt(),
          'height': height.toInt(),
          'dpr': _dpr,
        },
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await plugin.prepareContext();
    } on MissingPluginException {
      plugin.dispose();
      if (!mounted || _disposed) return;
      setState(() {
        _glError = '3D 渲染插件尚未注册。新增 flutter_gl 后需要完全停止应用并重新运行，热重载/热重启不会生效。';
      });
      return;
    } on Object catch (error) {
      plugin.dispose();
      if (!mounted || _disposed) return;
      setState(() {
        _glError = '3D 渲染初始化失败：$error';
      });
      return;
    } finally {
      _initializingGl = false;
    }

    if (!mounted || _disposed) {
      plugin.dispose();
      return;
    }

    _glPlugin = plugin;
    _initRenderer();
    _initScene();
    setState(() => _glReady = true);
    _ticker?.start();
    await _loadModel(widget.source);
  }

  void _initRenderer() {
    final plugin = _glPlugin!;
    _renderer =
        three.WebGLRenderer({
            'width': _width,
            'height': _height,
            'gl': plugin.gl,
            'antialias': true,
            'canvas': plugin.element,
          })
          ..setPixelRatio(_dpr)
          ..setSize(_width, _height, false)
          ..shadowMap.enabled = true;

    if (!kIsWeb) {
      final target = three.WebGLRenderTarget(
        (_width * _dpr).toInt(),
        (_height * _dpr).toInt(),
        three.WebGLRenderTargetOptions({
          'minFilter': three.LinearFilter,
          'magFilter': three.LinearFilter,
          'format': three.RGBAFormat,
        }),
      );
      target.samples = 4;
      _renderer!.setRenderTarget(target);
      _sourceTexture = _renderer!.getRenderTargetGLTexture(target);
    }
  }

  void _initScene() {
    final scene = three.Scene();
    scene.background = three.Color(0xF3F2F8);

    final camera = three.PerspectiveCamera(45, _width / _height, 0.01, 2000);
    camera.position.set(0, 1.2, 4.2);

    final hemi = three.HemisphereLight(0xffffff, 0x8a84a8, 0.95);
    scene.add(hemi);

    final key = three.DirectionalLight(0xffffff, 1.05);
    key.position.set(4, 8, 6);
    scene.add(key);

    final fill = three.DirectionalLight(0xd8d0ff, 0.45);
    fill.position.set(-5, 2, -4);
    scene.add(fill);

    final rim = three.DirectionalLight(0xffd9ef, 0.35);
    rim.position.set(0, 3, -6);
    scene.add(rim);

    final controls = three_jsm.OrbitControls(camera, _controlsKey);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    controls.screenSpacePanning = false;
    controls.minDistance = 0.4;
    controls.maxDistance = 40;
    controls.maxPolarAngle = math.pi * 0.92;
    controls.autoRotate = widget.autoRotate;
    controls.autoRotateSpeed = 1.6;

    _scene = scene;
    _camera = camera;
    _controls = controls;
    _sceneReady = true;
  }

  Future<void> _loadModel(ActionModelSource? source) async {
    if (!_sceneReady || _scene == null) return;

    setState(() {
      _loadingModel = true;
      _error = null;
    });

    _clearModel();

    if (source == null || !source.canRender) {
      if (mounted) {
        setState(() {
          _loadingModel = false;
          _error = source?.statusLabel;
        });
        widget.onAnimationsChanged?.call(const []);
      }
      return;
    }

    try {
      final loaded = await _loadObject(source);
      if (!mounted || _disposed || _scene == null) return;

      _modelRoot = loaded.object;
      _scene!.add(loaded.object);
      _captureBaseBoneRotations(loaded.object);
      _applyPose(widget.poseMode);
      _frameCamera(loaded.object);

      if (loaded.animations.isNotEmpty) {
        _mixer = three.AnimationMixer(loaded.object);
      }
      _animations = loaded.animations;
      final animationNames = _animationNames(loaded.animations);
      widget.onAnimationsChanged?.call(animationNames);
      _playAnimation(
        animationNames.contains(widget.selectedAnimationName)
            ? widget.selectedAnimationName
            : null,
      );

      setState(() {
        _loadingModel = false;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingModel = false;
        _error = '模型加载失败：$error';
      });
    }
  }

  Future<({three.Object3D object, List<three.AnimationClip> animations})>
  _loadObject(ActionModelSource source) async {
    switch (source.kind) {
      case ActionModelKind.gltf:
        final loader = three_jsm.GLTFLoader(null);
        if (source.loaderPath != null) {
          loader.setPath(source.loaderPath!);
        }
        final url = source.filePath ?? source.fileName!;
        final result = await loader.loadAsync(url);
        final scene = result['scene'] as three.Object3D;
        final animations = (result['animations'] as List? ?? [])
            .cast<three.AnimationClip>();
        return (object: scene, animations: animations);
      case ActionModelKind.obj:
        final loader = three_jsm.OBJLoader(null);
        if (source.loaderPath != null) {
          loader.setPath(source.loaderPath!);
        }
        final url = source.filePath ?? source.fileName!;
        final object = await loader.loadAsync(url) as three.Object3D;
        return (object: object, animations: <three.AnimationClip>[]);
      case ActionModelKind.unsupported:
        throw StateError('Unsupported model kind');
    }
  }

  void _clearModel() {
    final scene = _scene;
    final modelRoot = _modelRoot;
    if (scene != null && modelRoot != null) {
      scene.remove(modelRoot);
      modelRoot.traverse((child) {
        if (child is three.Mesh) {
          child.geometry?.dispose();
          if (child.material is three.Material) {
            (child.material as three.Material).dispose();
          } else if (child.material is List) {
            for (final material in child.material as List) {
              (material as three.Material).dispose();
            }
          }
        }
      });
    }
    _modelRoot = null;
    _mixer = null;
    _animations = const [];
    _baseBoneRotations.clear();
  }

  void _captureBaseBoneRotations(three.Object3D root) {
    _baseBoneRotations.clear();
    root.traverse((child) {
      if (child is three.Object3D && _boneRoleForName(child.name) != null) {
        _baseBoneRotations[child] = child.rotation.clone();
      }
    });
  }

  void _applyPose(ModelPoseMode poseMode) {
    if (_baseBoneRotations.isEmpty) return;

    for (final entry in _baseBoneRotations.entries) {
      entry.key.rotation.copy(entry.value);
    }

    if (poseMode == ModelPoseMode.sitting) {
      for (final entry in _baseBoneRotations.entries) {
        final role = _boneRoleForName(entry.key.name);
        final offset = role == null ? null : _poseOffset(role, poseMode);
        if (offset == null) continue;
        entry.key.rotation.set(
          entry.value.x + offset.x,
          entry.value.y + offset.y,
          entry.value.z + offset.z,
          entry.value.order,
        );
      }
    }

    _modelRoot?.updateMatrixWorld(true);
  }

  List<String> _animationNames(List<three.AnimationClip> animations) {
    return [
      for (var index = 0; index < animations.length; index += 1)
        _animationName(animations[index], index),
    ];
  }

  String _animationName(three.AnimationClip clip, int index) {
    final name = clip.name.trim();
    return name.isEmpty ? '动作 ${index + 1}' : name;
  }

  void _playAnimation(String? animationName) {
    final mixer = _mixer;
    final modelRoot = _modelRoot;
    if (mixer == null || modelRoot == null) return;

    mixer.stopAllAction();
    if (animationName == null) return;
    final animationIndex = _animationNames(_animations).indexOf(animationName);
    if (animationIndex < 0) return;
    final action = mixer.clipAction(_animations[animationIndex], modelRoot);
    action?.reset().play();
  }

  void _frameCamera(three.Object3D object) {
    final camera = _camera;
    final controls = _controls;
    if (camera == null || controls == null) return;

    final box = three.Box3().setFromObject(object);
    final center = box.getCenter(three.Vector3());
    final size = box.getSize(three.Vector3());
    final radius = math.max(size.x, math.max(size.y, size.z)) * 0.55;
    final distance = math.max(
      radius / math.sin((camera.fov * math.pi) / 360),
      1.2,
    );

    camera.position.set(
      center.x,
      center.y + radius * 0.15,
      center.z + distance * 1.35,
    );
    controls.target.set(center.x, center.y, center.z);
    controls.minDistance = distance * 0.35;
    controls.maxDistance = distance * 4.5;
    controls.update();
  }

  void _onTick(Duration elapsed) {
    if (!_glReady || _disposed || _renderer == null || _scene == null) return;
    final delta = _clock.getDelta();
    _mixer?.update(delta);
    _controls?.update();
    _render();
  }

  void _render() {
    final plugin = _glPlugin;
    final renderer = _renderer;
    final scene = _scene;
    final camera = _camera;
    if (plugin == null || renderer == null || scene == null || camera == null) {
      return;
    }

    renderer.render(scene, camera);
    plugin.gl.flush();
    if (!kIsWeb && _sourceTexture != null) {
      plugin.updateTexture(_sourceTexture);
    }
  }

  double _renderPixelRatio(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return dpr.clamp(1.0, 2.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (_usesModelViewerRenderer) {
      return _ModelViewerPlusPreview(
        source: widget.source,
        autoRotate: widget.autoRotate,
        poseMode: widget.poseMode,
        selectedAnimationName: widget.selectedAnimationName,
        onAnimationsChanged: widget.onAnimationsChanged,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!_glReady && width > 0 && height > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_ensureGl(width, height));
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            if (_glError == null)
              three_jsm.DomLikeListenable(
                key: _controlsKey,
                builder: (context) {
                  final plugin = _glPlugin;
                  if (plugin == null || !plugin.isInitialized) {
                    return const ColoredBox(color: AppColors.surface);
                  }
                  if (kIsWeb) {
                    return HtmlElementView(
                      viewType: plugin.textureId!.toString(),
                    );
                  }
                  return Texture(textureId: plugin.textureId!);
                },
              )
            else
              const ColoredBox(color: AppColors.surface),
            if (_glError != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _glError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            if (_loadingModel) const Center(child: CircularProgressIndicator()),
            if (_error != null && !_loadingModel)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            if (widget.source != null &&
                widget.source?.canRender != true &&
                _error == null &&
                !_loadingModel)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.source!.statusLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            if (widget.source == null && !_loadingModel)
              Center(
                child: Text(
                  '导入 GLTF/GLB/OBJ 模型查看真实材质效果',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ModelViewerPlusPreview extends StatelessWidget {
  const _ModelViewerPlusPreview({
    required this.source,
    required this.autoRotate,
    required this.poseMode,
    this.selectedAnimationName,
    this.onAnimationsChanged,
  });

  final ActionModelSource? source;
  final bool autoRotate;
  final ModelPoseMode poseMode;
  final String? selectedAnimationName;
  final ValueChanged<List<String>>? onAnimationsChanged;

  @override
  Widget build(BuildContext context) {
    final model = source;
    if (model == null) {
      return _ModelPreviewMessage(
        message: '导入 GLTF/GLB 模型查看真实材质效果',
        caption: '移动端使用 WebView 预览，避免 flutter_gl 原生渲染崩溃与卡死。',
      );
    }

    if (!model.canRender || model.kind == ActionModelKind.obj) {
      return _ModelPreviewMessage(
        message: model.statusLabel,
        caption: model.kind == ActionModelKind.obj
            ? '移动端预览当前支持 GLTF/GLB；OBJ 请在桌面端查看。'
            : '该格式会保留导入状态，等待后续渲染器支持。',
      );
    }

    return FutureBuilder<({String src, List<String> animationNames})>(
      future: _modelViewerPayload(model),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ModelPreviewMessage(
            message: '模型加载失败',
            caption: '${snapshot.error}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payload = snapshot.data!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAnimationsChanged?.call(payload.animationNames);
        });
        final animationName =
            payload.animationNames.contains(selectedAnimationName)
            ? selectedAnimationName
            : null;

        return model_viewer.ModelViewer(
          key: ValueKey(
            '${model.name}-${payload.src}-$autoRotate-$animationName-$poseMode',
          ),
          src: payload.src,
          alt: model.name,
          backgroundColor: AppColors.surface,
          cameraControls: true,
          autoRotate: autoRotate,
          autoRotateDelay: 0,
          animationName: animationName,
          autoPlay: animationName != null,
          ar: false,
          disableTap: false,
          debugLogging: false,
        );
      },
    );
  }

  Future<({String src, List<String> animationNames})> _modelViewerPayload(
    ActionModelSource source,
  ) async {
    final path = source.filePath;
    final fileName = source.fileName;
    if (path == null && fileName == null) {
      throw StateError('模型路径不存在。');
    }

    if (source.extension == 'glb') {
      final src = path != null
          ? Uri.file(path).toString()
          : '${source.loaderPath ?? ''}$fileName';
      return (src: src, animationNames: const <String>[]);
    }

    if (source.extension != 'gltf') {
      throw StateError('移动端预览仅支持 GLTF/GLB。');
    }

    final bytes = path != null
        ? await File(path).readAsBytes()
        : await _loadAssetBytes('${source.loaderPath ?? ''}$fileName');
    final basePath = path != null
        ? _parentPath(path, Platform.pathSeparator)
        : source.loaderPath ?? '';
    final document = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final animationNames = _animationNames(document);
    _applyPoseToDocument(document, poseMode);

    await _inlineGltfResources(
      document: document,
      basePath: basePath,
      fromFileSystem: path != null,
    );

    final encoded = base64Encode(utf8.encode(jsonEncode(document)));
    return (
      src: 'data:model/gltf+json;base64,$encoded',
      animationNames: animationNames,
    );
  }

  List<String> _animationNames(Map<String, dynamic> document) {
    final animations = document['animations'];
    if (animations is! List) return const [];

    return [
      for (var index = 0; index < animations.length; index += 1)
        if (animations[index] is Map)
          _animationName(animations[index] as Map, index),
    ];
  }

  String _animationName(Map animation, int index) {
    final name = animation['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    return '动作 ${index + 1}';
  }

  void _applyPoseToDocument(
    Map<String, dynamic> document,
    ModelPoseMode poseMode,
  ) {
    if (poseMode == ModelPoseMode.standing) return;

    final nodes = document['nodes'];
    if (nodes is! List) return;

    for (final node in nodes.whereType<Map>()) {
      if (node['matrix'] != null) continue;
      final name = node['name'];
      if (name is! String) continue;
      final role = _boneRoleForName(name);
      final offset = role == null ? null : _poseOffset(role, poseMode);
      if (offset == null) continue;

      final baseEuler = _nodeEuler(node);
      final posedEuler = (
        x: baseEuler.x + offset.x,
        y: baseEuler.y + offset.y,
        z: baseEuler.z + offset.z,
      );
      node['rotation'] = _quaternionFromEuler(posedEuler);
    }
  }

  ({double x, double y, double z}) _nodeEuler(Map node) {
    final rotation = node['rotation'];
    if (rotation is List && rotation.length == 4) {
      return _eulerFromQuaternion((
        x: (rotation[0] as num).toDouble(),
        y: (rotation[1] as num).toDouble(),
        z: (rotation[2] as num).toDouble(),
        w: (rotation[3] as num).toDouble(),
      ));
    }
    return (x: 0, y: 0, z: 0);
  }

  Future<void> _inlineGltfResources({
    required Map<String, dynamic> document,
    required String basePath,
    required bool fromFileSystem,
  }) async {
    final buffers = document['buffers'];
    if (buffers is List) {
      for (final buffer in buffers.whereType<Map>()) {
        await _inlineUri(
          target: buffer,
          key: 'uri',
          basePath: basePath,
          fromFileSystem: fromFileSystem,
          fallbackMimeType: 'application/octet-stream',
        );
      }
    }

    final images = document['images'];
    if (images is List) {
      for (final image in images.whereType<Map>()) {
        await _inlineUri(
          target: image,
          key: 'uri',
          basePath: basePath,
          fromFileSystem: fromFileSystem,
          fallbackMimeType:
              _mimeTypeForPath(image['uri'] as String?) ??
              'application/octet-stream',
        );
      }
    }
  }

  Future<void> _inlineUri({
    required Map target,
    required String key,
    required String basePath,
    required bool fromFileSystem,
    required String fallbackMimeType,
  }) async {
    final uri = target[key];
    if (uri is! String || uri.isEmpty || _isExternalUri(uri)) return;

    final resourcePath = _decodeResourceUri(uri);
    final bytes = fromFileSystem
        ? await File('$basePath$resourcePath').readAsBytes()
        : await _loadAssetBytes('$basePath$resourcePath');
    final mimeType = _mimeTypeForPath(uri) ?? fallbackMimeType;
    target[key] = 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  bool _isExternalUri(String uri) {
    return uri.startsWith('data:') ||
        uri.startsWith('http://') ||
        uri.startsWith('https://');
  }

  String _decodeResourceUri(String uri) {
    try {
      return Uri.decodeFull(uri);
    } on FormatException {
      return uri;
    }
  }

  String _parentPath(String path, String separator) {
    final slash = path.lastIndexOf(separator);
    if (slash < 0) return '';
    return path.substring(0, slash + 1);
  }

  String? _mimeTypeForPath(String? path) {
    final value = path?.toLowerCase();
    if (value == null) return null;
    if (value.endsWith('.png')) return 'image/png';
    if (value.endsWith('.jpg') || value.endsWith('.jpeg')) return 'image/jpeg';
    if (value.endsWith('.webp')) return 'image/webp';
    if (value.endsWith('.bin')) return 'application/octet-stream';
    return null;
  }

  Future<Uint8List> _loadAssetBytes(String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

class _ModelPreviewMessage extends StatelessWidget {
  const _ModelPreviewMessage({required this.message, required this.caption});

  final String message;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_in_ar_outlined,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.72),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

Future<ActionModelSource?> actionModelSourceFromFile(PlatformFile file) async {
  final extension = (file.extension ?? file.name.split('.').last).toLowerCase();
  final sizeBytes = file.size;

  if (extension == 'pmx' || extension == 'vrm') {
    return ActionModelSource(
      name: file.name,
      extension: extension,
      sizeBytes: sizeBytes,
      kind: ActionModelKind.unsupported,
    );
  }

  if (extension == 'gltf' || extension == 'glb' || extension == 'obj') {
    if (file.path != null && !kIsWeb) {
      final path = file.path!;
      final separator = Platform.pathSeparator;
      final slash = path.lastIndexOf(separator);
      final dir = slash >= 0 ? path.substring(0, slash + 1) : '';
      final fileName = slash >= 0 ? path.substring(slash + 1) : path;
      return ActionModelSource(
        name: file.name,
        extension: extension,
        sizeBytes: sizeBytes,
        kind: extension == 'obj' ? ActionModelKind.obj : ActionModelKind.gltf,
        loaderPath: dir,
        fileName: fileName,
        filePath: path,
      );
    }
  }

  return ActionModelSource(
    name: file.name,
    extension: extension,
    sizeBytes: sizeBytes,
    kind: ActionModelKind.unsupported,
  );
}

// PlatformFile import comes from file_picker above.
