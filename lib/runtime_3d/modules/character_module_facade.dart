import '../contracts/model_contract.dart';
import '../../features/action/presentation/models/action_model_source.dart';
import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class CharacterModuleFacade {
  CharacterModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> load(ActionModelSource? source) {
    if (source == null || !source.canRender) {
      return clear();
    }
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'character',
      action: 'load',
      payload: ModelLoadPayload.fromSource(source).toJson(),
    ));
  }

  Future<void> clear() {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'character',
      action: 'clear',
    ));
  }
}
