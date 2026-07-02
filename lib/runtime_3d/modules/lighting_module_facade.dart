import '../contracts/lighting_contract.dart';
import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class LightingModuleFacade {
  LightingModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> applyRig(LightingRigJson rig) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'lighting',
      action: 'applyRig',
      payload: rig,
    ));
  }

  Future<void> selectLight(String lightId) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'lighting',
      action: 'selectLight',
      payload: {'id': lightId},
    ));
  }
}
