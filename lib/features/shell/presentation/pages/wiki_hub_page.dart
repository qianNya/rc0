import 'package:flutter/material.dart';

import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../character/presentation/pages/character_list_page.dart';
import '../../../character/presentation/widgets/character_wiki_app_bar.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../widgets/wiki_ip_tab.dart';

class WikiHubPage extends StatefulWidget {
  const WikiHubPage({
    super.key,
    this.initialTabIndex = 0,
    this.initialDiscoverySection,
  });

  final int initialTabIndex;

  /// Kept for `/discovery?section=template` deep links; discovery is now a
  /// single template market page and no longer switches tabs.
  final String? initialDiscoverySection;

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
        return const ExplorePage(embeddedInHub: true);
      case _WikiSection.ip:
        return const WikiIpTab();
      case _WikiSection.character:
        return const CharacterListPage(embeddedInHub: true);
    }
  }

  Widget _buildLazySection(_WikiSection section) {
    if (!_loadedSections.contains(section)) {
      return const SizedBox.shrink();
    }
    return _KeepAliveSection(child: _buildSectionContent(section));
  }

  Widget _buildBody() {
    return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadedSections.add(_activeSection);

    final body = _buildBody();

    if (_activeSection == _WikiSection.discovery) {
      return body;
    }

    final PreferredSizeWidget appBar = switch (_activeSection) {
      _WikiSection.character => const CharacterHubAppBar(),
      _WikiSection.ip => const WikiModeTagAppBar(title: 'IP'),
      _WikiSection.discovery => const WikiModeTagAppBar(title: '模板'),
    };

    final desktopHeader = switch (_activeSection) {
      _WikiSection.character => const DesktopHubHeader(
          title: '角色',
          subtitle: '角色库与可复用形象',
        ),
      _WikiSection.ip => const DesktopHubHeader(
          title: 'IP',
          subtitle: '作品宇宙与世界观',
        ),
      _WikiSection.discovery => null,
    };

    return DesktopHubScaffold(
      appBar: appBar,
      desktopHeader: desktopHeader,
      body: body,
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
