import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';
import '../widgets/character_library_body.dart';
import '../widgets/character_wiki_app_bar.dart';

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
    final chromeTop = wikiModeTagContentInsetHeight(context);
    final title = widget.workId != null ? 'IP 角色' : '角色库';

    final body = Padding(
      padding: EdgeInsets.only(top: chromeTop),
      child: CharacterLibraryBody(
        mode: CharacterLibraryMode.wiki,
        workId: widget.workId,
        embeddedInHub: widget.embeddedInHub,
        externalChromeInset: true,
        lightTone: true,
        keepAlive: widget.embeddedInHub,
        showAiFab: true,
      ),
    );

    if (widget.embeddedInHub) {
      return Theme(data: AppTheme.light, child: body);
    }

    return Theme(
      data: AppTheme.light,
      child: CharacterHubScaffold(
        appBar: CharacterHubAppBar(
          title: title,
          actions: [
            WikiModeTagIconButton(
              icon: Icons.folder_outlined,
              tooltip: '我的角色',
              onPressed: () => context.push(AppRoutes.myCharacters),
            ),
            if (_auth.isLoggedIn)
              WikiModeTagIconButton(
                icon: Icons.add,
                tooltip: '新建角色',
                onPressed: () => context.push(AppRoutes.characterCreate),
              ),
            const ScriptStudioHeaderActionButtons(trailingSpacing: 8),
          ],
        ),
        body: body,
      ),
    );
  }
}
