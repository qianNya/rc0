import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../widgets/character_library_body.dart';

class CharacterListPage extends StatefulWidget {
  const CharacterListPage({
    super.key,
    this.workId,
    this.embeddedInHub = false,
  });

  final int? workId;
  final bool embeddedInHub;

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final _auth = AuthRepository.instance;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = CharacterLibraryBody(
      mode: CharacterLibraryMode.discovery,
      workId: widget.workId,
      embeddedInHub: widget.embeddedInHub,
      showAiFab: widget.embeddedInHub,
    );

    if (widget.embeddedInHub) return body;

    return DesktopStackScaffold(
      title: Text(widget.workId != null ? 'IP 角色' : '角色库'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        IconButton(
          tooltip: '我的角色',
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => context.push(AppRoutes.myCharacters),
        ),
        if (_auth.isLoggedIn)
          IconButton(
            tooltip: '新建角色',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.characterCreate),
          ),
      ],
      floatingActionButton: StudioEditorShellGlassButton(
        label: 'AI 角色',
        icon: Icons.auto_awesome,
        minWidth: 120,
        onPressed: () => context.push(AppRoutes.characterAi),
      ),
      body: body,
    );
  }
}
