import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../user/data/user_screenplays_repository.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../widgets/script_studio_action_cards.dart';
import '../widgets/script_studio_app_bar.dart';
import '../widgets/script_studio_backdrop.dart';
import '../widgets/script_studio_quick_start.dart';
import '../widgets/script_studio_recent_section.dart';
import '../widgets/script_studio_theme.dart';

class ScriptStudioPage extends StatefulWidget {
  const ScriptStudioPage({super.key});

  @override
  State<ScriptStudioPage> createState() => _ScriptStudioPageState();
}

class _ScriptStudioPageState extends State<ScriptStudioPage> {
  final _local = ScreenplayLocalRepository.instance;
  final _auth = AuthRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
    _auth.addListener(_onAuthChanged);
    _screenplays.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRemoteRecent());
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    _auth.removeListener(_onAuthChanged);
    _screenplays.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);
  void _onAuthChanged() {
    scheduleSetState(this);
    _loadRemoteRecent();
  }

  Future<void> _loadRemoteRecent() async {
    final profile = _auth.profile;
    if (!_auth.isLoggedIn || profile == null) {
      _userId = null;
      return;
    }
    final userId = profile.id.toInt();
    _userId = userId;
    await _screenplays.loadFirstPage(userId);
  }

  List<Screenplay> get _recentProjects {
    final local = List<Screenplay>.from(_local.localScreenplays);
    final remote = _userId != null ? _screenplays.itemsFor(_userId!) : const <Screenplay>[];

    // If a local draft has already been published, keep local copy first.
    final localRemoteIds = local
        .map((s) => s.remoteScreenplayId)
        .whereType<int>()
        .toSet();
    final merged = <Screenplay>[
      ...local,
      ...remote.where(
        (s) => s.remoteScreenplayId == null || !localRemoteIds.contains(s.remoteScreenplayId),
      ),
    ];

    final items = List<Screenplay>.from(merged);
    items.sort((a, b) {
      final aTime = a.updatedAt ??
          a.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ??
          b.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items.take(5).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ScriptStudioColors.background,
        extendBodyBehindAppBar: true,
        appBar: const ScriptStudioAppBar(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ScriptStudioBackdrop(),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                const _ScriptStudioTopInset(),
                const ScriptStudioActionCards(),
                ScriptStudioRecentSection(
                  projects: _recentProjects,
                  onDataChanged: _onChanged,
                ),
                const ScriptStudioQuickStart(),
                const ShellBottomSpacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScriptStudioTopInset extends StatelessWidget {
  const _ScriptStudioTopInset();

  @override
  Widget build(BuildContext context) {
    final statusTop = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: statusTop + kToolbarHeight - AppDimensions.spacingXl,
    );
  }
}
