import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../core/responsive/breakpoints.dart';
import '../desktop/desktop_stack_scaffold.dart';
import '../feed_tab_bar.dart';
import '../rc0_page_scaffold.dart';
import '../wiki_mode_tag_app_bar.dart';

/// Search page shell with query field and segmented result tabs.
class GlassSearchScaffold extends StatelessWidget {
  const GlassSearchScaffold({
    super.key,
    required this.hint,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.tabLabels,
    required this.tabIndex,
    required this.onTabChanged,
    required this.body,
    this.onBack,
    this.actions = const [],
  });

  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final List<String> tabLabels;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final Widget body;
  final VoidCallback? onBack;
  final List<Widget> actions;

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WikiModeTagToolbarInset(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            0,
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search, size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: FeedTabBar(
            tabs: tabLabels,
            selectedIndex: tabIndex,
            onChanged: onTabChanged,
            embedded: true,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(child: body),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildBody();

    if (Breakpoints.isDesktop(context)) {
      return DesktopStackScaffold(
        title: const Text('搜索'),
        onBack: onBack ?? () => Navigator.maybePop(context),
        actions: actions,
        body: content,
      );
    }

    return Rc0PageScaffold(
      title: const Text('搜索'),
      onBack: onBack ?? () => Navigator.maybePop(context),
      actions: actions,
      body: content,
    );
  }
}
