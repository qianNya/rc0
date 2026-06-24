import 'package:flutter/material.dart';

import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../widgets/script_studio_action_cards.dart';
import '../widgets/script_studio_app_bar.dart';
import '../widgets/script_studio_quick_start.dart';
import '../widgets/script_studio_recent_section.dart';

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
    return Scaffold(
      appBar: const ScriptStudioAppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const ScriptStudioActionCards(),
          ScriptStudioRecentSection(
            projects: _recentProjects,
            onDataChanged: _onChanged,
          ),
          const ScriptStudioQuickStart(),
        ],
      ),
    );
  }
}
