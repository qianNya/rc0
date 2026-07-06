import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../messages/data/messages_repository.dart';

class InboxMessagesTab extends StatefulWidget {
  const InboxMessagesTab({super.key});

  @override
  State<InboxMessagesTab> createState() => _InboxMessagesTabState();
}

class _InboxMessagesTabState extends State<InboxMessagesTab> {
  final _repo = MessagesRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
    _repo.load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  @override
  Widget build(BuildContext context) {
    if (_repo.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_repo.threads.isEmpty) {
      return const Center(
        child: GlassEmptyState(
          icon: Icons.chat_bubble_outline,
          title: '暂无消息',
          subtitle: '互动与系统通知将显示在这里',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: _repo.threads.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final thread = _repo.threads[index];
        return GlassCard(
          padding: EdgeInsets.zero,
          child: GlassListRow(
            title: thread.title,
            subtitle: thread.preview,
            leading: const Icon(Icons.forum_outlined),
            trailing: thread.unread > 0
                ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${thread.unread}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
