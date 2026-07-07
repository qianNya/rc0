import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';
import '../widgets/character_library_body.dart';
import '../widgets/character_wiki_app_bar.dart';

class CharacterListPage extends ConsumerStatefulWidget {
  const CharacterListPage({
    super.key,
    this.workId,
    this.embeddedInHub = false,
  });

  final int? workId;
  final bool embeddedInHub;

  @override
  ConsumerState<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends ConsumerState<CharacterListPage> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
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
            if (isLoggedIn)
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
