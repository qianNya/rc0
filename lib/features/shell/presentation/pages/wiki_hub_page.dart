import 'package:flutter/material.dart';

import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../character/presentation/widgets/wiki/wiki_character_library_tab.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../widgets/wiki_ip_tab.dart';

class WikiHubPage extends StatefulWidget {
  const WikiHubPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<WikiHubPage> createState() => _WikiHubPageState();
}

enum _WikiSection {
  discovery,
  ip,
  character;

  static _WikiSection fromIndex(int raw) {
    final max = _WikiSection.values.length - 1;
    return _WikiSection.values[raw.clamp(0, max)];
  }
}

class _WikiHubPageState extends State<WikiHubPage> {
  _WikiSection _activeSection = _WikiSection.discovery;
  final Set<_WikiSection> _loadedSections = <_WikiSection>{};

  @override
  void initState() {
    super.initState();
    _syncSectionFromWidget();
  }

  @override
  void didUpdateWidget(covariant WikiHubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _syncSectionFromWidget();
    }
  }

  void _syncSectionFromWidget() {
    _activeSection = _WikiSection.fromIndex(widget.initialTabIndex);
    _loadedSections.add(_activeSection);
  }

  Widget _buildSectionContent(_WikiSection section) {
    switch (section) {
      case _WikiSection.discovery:
        return const ExplorePage(
          embeddedInHub: true,
          showInlineSearchAction: false,
          showInlineFeedTabs: false,
        );
      case _WikiSection.ip:
        return const WikiIpTab();
      case _WikiSection.character:
        return const WikiCharacterLibraryTab();
    }
  }

  Widget _buildLazySection(_WikiSection section) {
    if (!_loadedSections.contains(section)) {
      return const SizedBox.shrink();
    }
    return _KeepAliveSection(child: _buildSectionContent(section));
  }

  @override
  Widget build(BuildContext context) {
    _loadedSections.add(_activeSection);

    final title = switch (_activeSection) {
      _WikiSection.discovery => '发现',
      _WikiSection.ip => 'IP',
      _WikiSection.character => '角色',
    };

    return WikiModeTagPageScaffold(
      appBar: WikiModeTagAppBar(title: title),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FadeSlideIndexedStack(
                index: _activeSection.index,
                children: _WikiSection.values
                    .map(_buildLazySection)
                    .toList(growable: false),
              ),
            ),
          ],
        ),
    );
  }
}

class _KeepAliveSection extends StatefulWidget {
  const _KeepAliveSection({required this.child});

  final Widget child;

  @override
  State<_KeepAliveSection> createState() => _KeepAliveSectionState();
}

class _KeepAliveSectionState extends State<_KeepAliveSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
