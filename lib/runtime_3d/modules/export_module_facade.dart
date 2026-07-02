import '../core/runtime_command.dart';
import '../core/runtime_session.dart';

class ExportModuleFacade {
  ExportModuleFacade(this._session);

  final RuntimeSession _session;

  Future<void> capturePng() {
    return _session.send(RuntimeCommand(
      sessionId: _session.sessionId,
      module: 'export',
      action: 'capturePng',
    ));
  }
}
