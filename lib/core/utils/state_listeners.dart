import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Schedules [setState] after the current frame to avoid build-phase updates.
void scheduleSetState(State state, [VoidCallback? update]) {
  if (!state.mounted) return;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!state.mounted) return;
    if (update != null) {
      state.setState(update);
    } else {
      state.setState(() {});
    }
  });
}
