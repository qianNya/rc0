import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/studio/presentation/studio_editor_shell_bridge.dart';

void main() {
  tearDown(StudioEditorShellBridge.instance.clear);

  test('saveFromShell calls local save without navigation or frame requirement',
      () async {
    bool? goHomeArg;
    bool? requireFramesArg;

    StudioEditorShellBridge.instance.register(
      onSaveLocal: ({bool goHome = true, bool? requireFrames}) async {
        goHomeArg = goHome;
        requireFramesArg = requireFrames;
      },
    );

    await StudioEditorShellBridge.instance.saveFromShell();

    expect(goHomeArg, isFalse);
    expect(requireFramesArg, isFalse);
  });

  test('saveFromShell is skipped while saveBusy', () async {
    var calls = 0;

    StudioEditorShellBridge.instance.register(
      onSaveLocal: ({bool goHome = true, bool? requireFrames}) async {
        calls++;
      },
      saveBusy: true,
    );

    await StudioEditorShellBridge.instance.saveFromShell();

    expect(calls, 0);
  });
}
