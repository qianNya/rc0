import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../widgets/inbox_messages_tab.dart';
import '../widgets/inbox_tasks_tab.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('收件箱'),
      onBack: () => popOrGoDiscovery(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FeedTabBar(
              tabs: const ['消息', '任务'],
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
              embedded: true,
            ),
          ),
          Expanded(
            child: FadeSlideIndexedStack(
              index: _tabIndex,
              children: const [
                InboxMessagesTab(),
                InboxTasksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
