import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';
import '../../data/asset_repository.dart';
import '../widgets/assets_wiki_app_bar.dart';
import '../widgets/wiki_assets_tab.dart';

/// Shell「资产」tab — in-page switching between built-in libraries and custom items.
class AssetsHubPage extends StatefulWidget {
  const AssetsHubPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<AssetsHubPage> createState() => _AssetsHubPageState();
}

class _AssetsHubPageState extends State<AssetsHubPage> {
  final _repo = AssetRepository.instance;
  late int _tabIndex;
  bool _refreshing = false;

  static const _tabs = ['内置库', '我的'];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _repo.addListener(_onRepo);
    _repo.load().then((_) {
      if (mounted) _repo.refreshFromApi();
    });
  }

  @override
  void didUpdateWidget(covariant AssetsHubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      setState(() {
        _tabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
      });
    }
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _repo.refreshFromApi();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.useSidebarShell(context);
    final chromeTop = wikiModeTagContentInsetHeight(context);
    final horizontal =
        desktop ? AppDimensions.spacingXl : AppDimensions.spacingMd;

    final tabBar = WikiModeTagTabBar(
      tabs: _tabs,
      selectedIndex: _tabIndex,
      onChanged: (index) => setState(() => _tabIndex = index),
    );

    return AssetsHubScaffold(
      appBar: AssetsHubAppBar(
        actions: [
          WikiModeTagIconButton(
            icon: Icons.refresh_rounded,
            onPressed: _refreshing ? null : _onRefresh,
            tooltip: '刷新',
          ),
          const ScriptStudioHeaderActionButtons(trailingSpacing: 8),
        ],
      ),
      desktopHeader: DesktopHubHeader(
        title: '资产',
        subtitle: '角色 · 设备 · 可复用素材',
        actions: [
          WikiModeTagIconButton(
            icon: Icons.refresh_rounded,
            onPressed: _refreshing ? null : _onRefresh,
            tooltip: '刷新',
          ),
        ],
        bottom: tabBar,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: desktop ? 0 : chromeTop),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!desktop) ...[
                tabBar,
                const SizedBox(height: AppDimensions.spacingSm),
              ],
              if (_repo.lastError != null)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                  child: Text(
                    _repo.lastError!,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: FadeSlideIndexedStack(
                  index: _tabIndex,
                  children: const [
                    WikiAssetsTab(
                      section: AssetsTabSection.builtin,
                      embeddedInShell: true,
                      showHeader: false,
                    ),
                    WikiAssetsTab(
                      section: AssetsTabSection.custom,
                      embeddedInShell: true,
                      showHeader: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
