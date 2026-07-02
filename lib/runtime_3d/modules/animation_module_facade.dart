import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class AnimationModuleFacade {
  AnimationModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> play(String? clipName) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'animation',
      action: 'play',
      payload: {'name': clipName},
    ));
  }

  Future<void> stop() {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'animation',
      action: 'stop',
    ));
  }
}
