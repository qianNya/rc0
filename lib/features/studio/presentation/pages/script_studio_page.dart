import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  List<Screenplay> get _recentProjects {
    final items = List<Screenplay>.from(_local.localScreenplays);
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items.take(5).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
