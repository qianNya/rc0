import 'package:flutter/material.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../character_library_body.dart';

/// Wiki Hub「角色」分段 — 双列角色库，对齐剧本工坊顶栏与亮调页面。
class WikiCharacterLibraryTab extends StatefulWidget {
  const WikiCharacterLibraryTab({super.key});

  @override
  State<WikiCharacterLibraryTab> createState() => _WikiCharacterLibraryTabState();
}

class _WikiCharacterLibraryTabState extends State<WikiCharacterLibraryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chromeTop = wikiModeTagContentInsetHeight(context);

    return Theme(
      data: AppTheme.light,
      child: Padding(
        padding: EdgeInsets.only(top: chromeTop),
        child: const CharacterLibraryBody(
          mode: CharacterLibraryMode.wiki,
          embeddedInHub: true,
          externalChromeInset: true,
          lightTone: true,
          keepAlive: true,
          showAiFab: true,
        ),
      ),
    );
  }
}
