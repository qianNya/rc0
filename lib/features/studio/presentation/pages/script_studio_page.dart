import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../user/data/user_screenplays_repository.dart';
import '../widgets/script_studio_action_cards.dart';
import '../widgets/script_studio_app_bar.dart';
import '../widgets/script_studio_quick_start.dart';
import '../widgets/script_studio_recent_section.dart';
import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';

class ScriptStudioPage extends ConsumerStatefulWidget {
  const ScriptStudioPage({super.key});

  @override
  ConsumerState<ScriptStudioPage> createState() => _ScriptStudioPageState();
}

class _ScriptStudioPageState extends ConsumerState<ScriptStudioPage> {
  final _local = ScreenplayLocalRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
    _screenplays.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRemoteRecent());
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    _screenplays.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  Future<void> _loadRemoteRecent() async {
    final session = ref.read(authSessionProvider);
    if (!session.isLoggedIn || session.profile == null) {
      if (mounted) setState(() => _userId = null);
      return;
    }
    final userId = session.profile!.id.toInt();
    if (mounted) setState(() => _userId = userId);
    await _screenplays.loadFirstPage(userId);
  }

  List<Screenplay> get _recentProjects {
    final local = List<Screenplay>.from(_local.localScreenplays);
    final remote = _userId != null
        ? _screenplays.itemsFor(_userId!)
        : const <Screenplay>[];

    final localRemoteIds =
        local.map((s) => s.remoteScreenplayId).whereType<int>().toSet();
    final merged = <Screenplay>[
      ...local,
      ...remote.where(
        (s) =>
            s.remoteScreenplayId == null ||
            !localRemoteIds.contains(s.remoteScreenplayId),
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
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.isLoggedIn != next.isLoggedIn ||
          previous?.profile?.id != next.profile?.id) {
        _loadRemoteRecent();
      }
    });

    final desktop = Breakpoints.useSidebarShell(context);
    final recent = ScriptStudioRecentSection(
      projects: _recentProjects,
      onDataChanged: _onChanged,
    );
    const quickStart = ScriptStudioQuickStart();

    final content = desktop
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXl,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: ScriptStudioActionCards(),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXl),
                Expanded(
                  flex: 6,
                  child: ListView(
                    children: [
                      recent,
                      quickStart,
                      const ShellBottomSpacer(extra: AppDimensions.spacingMd),
                    ],
                  ),
                ),
              ],
            ),
          )
        : ListView(
            padding: EdgeInsets.only(
              top: wikiModeTagContentInsetHeight(context),
            ),
            children: [
              const ScriptStudioActionCards(),
              recent,
              quickStart,
              const ShellBottomSpacer(extra: AppDimensions.spacingMd),
            ],
          );

    return ScriptStudioHubScaffold(
      appBar: const ScriptStudioAppBar(),
      desktopHeader: const DesktopHubHeader(
        title: '创作',
        subtitle: '从空白、模板或 AI 开始一部新作品',
      ),
      body: content,
    );
  }
}
