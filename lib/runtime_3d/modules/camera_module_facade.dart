import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class CameraModuleFacade {
  CameraModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> reset() {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'camera',
      action: 'reset',
    ));
  }

  Future<void> setPlanView(bool enabled) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'camera',
      action: 'setPlanView',
      payload: {'enabled': enabled},
    ));
  }

  Future<void> setAutoRotate(bool enabled) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'camera',
      action: 'setAutoRotate',
      payload: {'enabled': enabled},
    ));
  }
}
