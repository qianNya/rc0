import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../data/screenplay_delete_options.dart';
import '../../data/screenplay_local_repository.dart';
import '../../data/screenplay_remote_delete_service.dart';

Future<ScreenplayDeleteConfirmation> confirmDeleteScreenplays(
  BuildContext context, {
  required List<Screenplay> scripts,
}) async {
  if (scripts.isEmpty) {
    return const ScreenplayDeleteConfirmation(confirmed: false);
  }

  if (scripts.length == 1) {
    return _confirmSingle(context, scripts.first);
  }
  return _confirmBatch(context, scripts);
}

Future<ScreenplayDeleteConfirmation> _confirmSingle(
  BuildContext context,
  Screenplay script,
) async {
  final canDeleteRemote = screenplayCanDeleteRemote(script);
  final isFork = script.isForkCopy;
  var deleteRemote = false;

  final result = await showGlassDialog<bool>(
    context,
    child: StatefulBuilder(
      builder: (context, setState) => GlassDialog(
        title: const Text('删除剧本'),
        onClose: () => Navigator.pop(context, false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFork
                  ? '确定删除 Fork 副本「${script.title}」？仅删除本地副本，不影响原稿。'
                  : '确定删除「${script.title}」？本地文件将一并清除。',
            ),
            if (canDeleteRemote) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: deleteRemote,
                onChanged: (v) => setState(() => deleteRemote = v ?? false),
                title: const Text('同时删除云端副本'),
              ),
            ],
          ],
        ),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (result != true) {
    return const ScreenplayDeleteConfirmation(confirmed: false);
  }
  return ScreenplayDeleteConfirmation(
    confirmed: true,
    deleteRemote: deleteRemote && canDeleteRemote,
  );
}

Future<ScreenplayDeleteConfirmation> _confirmBatch(
  BuildContext context,
  List<Screenplay> scripts,
) async {
  final canDeleteRemote = anyScreenplayCanDeleteRemote(scripts);
  var deleteRemote = false;

  final result = await showGlassDialog<bool>(
    context,
    child: StatefulBuilder(
      builder: (context, setState) => GlassDialog(
        title: const Text('删除剧本'),
        onClose: () => Navigator.pop(context, false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('确定删除选中的 ${scripts.length} 个剧本？本地文件将一并清除。'),
            if (canDeleteRemote) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: deleteRemote,
                onChanged: (v) => setState(() => deleteRemote = v ?? false),
                title: const Text('同时删除云端副本'),
                subtitle: const Text('仅对已发布且非 Fork 的剧本生效'),
              ),
            ],
          ],
        ),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (result != true) {
    return const ScreenplayDeleteConfirmation(confirmed: false);
  }
  return ScreenplayDeleteConfirmation(
    confirmed: true,
    deleteRemote: deleteRemote && canDeleteRemote,
  );
}

Future<bool> confirmDeleteScreenplay(
  BuildContext context, {
  required Screenplay script,
}) async {
  final result = await confirmDeleteScreenplays(context, scripts: [script]);
  return result.confirmed;
}

Future<bool> confirmDeleteNode(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showGlassDialog<bool>(
    context,
    child: GlassDialog(
      title: Text(title),
      onClose: () => Navigator.pop(context, false),
      child: Text(message),
      footer: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

void showDeleteResultSnackBar(
  BuildContext context, {
  required int deleted,
  List<String> errors = const [],
  List<String> warnings = const [],
}) {
  String message;
  if (deleted == 0) {
    message = errors.isNotEmpty ? errors.first : '删除失败，请重试';
  } else if (errors.isEmpty) {
    message = warnings.isNotEmpty
        ? '已删除 $deleted 个剧本（部分云端副本已不存在）'
        : deleted == 1
            ? '剧本已删除'
            : '已删除 $deleted 个剧本';
  } else {
    message = '已删除 $deleted 个，${errors.length} 个失败：${errors.first}';
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmAndDeleteScreenplays(
  BuildContext context,
  List<Screenplay> scripts,
) async {
  final repo = ScreenplayLocalRepository.instance;
  final localScripts = scripts
      .where((s) => s.isLocal)
      .map((s) => (script: s, localId: repo.resolveLocalId(s)))
      .where((e) => e.localId != null)
      .toList();

  if (localScripts.isEmpty) return false;

  final confirmation = await confirmDeleteScreenplays(
    context,
    scripts: localScripts.map((e) => e.script).toList(),
  );
  if (!confirmation.confirmed || !context.mounted) return false;

  final result = await repo.deleteScreenplays(
    localScripts.map((e) => e.localId!).toList(),
    options: ScreenplayDeleteOptions(deleteRemote: confirmation.deleteRemote),
  );

  if (!context.mounted) return result.deleted > 0;

  showDeleteResultSnackBar(
    context,
    deleted: result.deleted,
    errors: result.errors,
    warnings: result.warnings,
  );
  return result.deleted > 0 && result.errors.isEmpty;
}

Future<bool> deleteScreenplayAndPop(
  BuildContext context, {
  required Screenplay script,
}) async {
  final repo = ScreenplayLocalRepository.instance;
  final localId = repo.resolveLocalId(script);

  final confirmation = await confirmDeleteScreenplays(context, scripts: [script]);
  if (!confirmation.confirmed || !context.mounted) return false;

  if (localId == null) {
    if (!confirmation.deleteRemote || script.remoteScreenplayId == null) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到本地副本，无法删除')),
      );
      return false;
    }
    final remoteResult = await ScreenplayRemoteDeleteService.instance
        .deleteScreenplay(script.remoteScreenplayId!);
    if (!context.mounted) return false;
    if (!remoteResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(remoteResult.error ?? '云端删除失败')),
      );
      return false;
    }
    showDeleteResultSnackBar(
      context,
      deleted: 1,
      warnings: remoteResult.warning != null ? [remoteResult.warning!] : [],
    );
    popOrGoExplore(context);
    return true;
  }

  final result = await repo.deleteScreenplay(
    localId,
    options: ScreenplayDeleteOptions(deleteRemote: confirmation.deleteRemote),
  );
  if (!context.mounted) return result.success;

  if (result.success) {
    showDeleteResultSnackBar(
      context,
      deleted: 1,
      warnings: result.warning != null ? [result.warning!] : [],
    );
    popOrGoExplore(context);
  } else {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(result.error ?? '删除失败，请重试')),
      );
  }
  return result.success;
}
