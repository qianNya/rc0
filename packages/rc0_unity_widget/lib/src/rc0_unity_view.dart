import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'rc0_unity_platform.dart';

/// Embeds the Unity player as a Flutter platform view (or WebGL iframe on web).
class Rc0UnityView extends StatefulWidget {
  const Rc0UnityView({
    super.key,
    required this.sessionId,
    this.onViewCreated,
    this.placeholder,
  });

  final String sessionId;
  final ValueChanged<int>? onViewCreated;
  final Widget? placeholder;

  @override
  State<Rc0UnityView> createState() => _Rc0UnityViewState();
}

class _Rc0UnityViewState extends State<Rc0UnityView> {
  bool _unityAvailable = false;
  bool _checked = false;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _checkUnity();
  }

  Future<void> _checkUnity() async {
    final available = await Rc0UnityPlatform.instance.isUnityAvailable();
    if (!mounted) return;
    setState(() {
      _unityAvailable = available;
      _checked = true;
    });
    if (available) {
      final id = await Rc0UnityPlatform.instance.createView(
        sessionId: widget.sessionId,
      );
      if (!mounted) return;
      setState(() => _viewId = id);
      if (id != null) widget.onViewCreated?.call(id);
    }
  }

  @override
  void dispose() {
    final id = _viewId;
    if (id != null) {
      Rc0UnityPlatform.instance.disposeView(id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (!_unityAvailable || _viewId == null) {
      return widget.placeholder ?? const _UnityUnavailablePlaceholder();
    }

    if (kIsWeb) {
      return HtmlElementView(viewType: 'rc0-unity-view-${widget.sessionId}');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'rc0-unity-view-android',
        creationParams: {
          'sessionId': widget.sessionId,
          'viewId': _viewId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'rc0-unity-view-ios',
        creationParams: {
          'sessionId': widget.sessionId,
          'viewId': _viewId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return AppKitView(
        viewType: 'rc0-unity-view-macos',
        creationParams: {
          'sessionId': widget.sessionId,
          'viewId': _viewId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    // Windows desktop POC placeholder.
    return ColoredBox(
      color: const Color(0xFF121018),
      child: Center(
        child: Text(
          'Unity · ${widget.sessionId}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _UnityUnavailablePlaceholder extends StatelessWidget {
  const _UnityUnavailablePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_in_ar_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Unity 运行时未链接',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '请从 unity/rc0_runtime 导出 Unity 库到 packages/rc0_unity_widget，'
              '然后完全重启应用。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
