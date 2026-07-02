import '../contracts/pose_contract.dart';
import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class PoseModuleFacade {
  PoseModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> apply(ModelPoseMode mode) {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'pose',
      action: 'apply',
      payload: {'mode': mode.wireName},
    ));
  }
}
