import 'package:flutter/material.dart';
import '../character_library_body.dart';

/// Wiki Hub「角色」分段 — 双列角色库，对齐产品设计稿。
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
    return const CharacterLibraryBody(
      mode: CharacterLibraryMode.wiki,
      embeddedInHub: true,
      keepAlive: true,
      showAiFab: true,
    );
  }
}
