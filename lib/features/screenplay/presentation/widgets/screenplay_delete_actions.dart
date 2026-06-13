import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../data/screenplay_local_repository.dart';

Future<bool> confirmDeleteScreenplay(
  BuildContext context, {
  required String title,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('删除剧本'),
      content: Text('确定删除「$title」？此操作不可恢复，相关图片将一并删除。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> deleteScreenplayAndPop(
  BuildContext context, {
  required String id,
  required String title,
}) async {
  final confirmed = await confirmDeleteScreenplay(context, title: title);
  if (!confirmed || !context.mounted) return false;

  final deleted = await ScreenplayLocalRepository.instance.delete(id);
  if (!context.mounted) return deleted;

  if (deleted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('剧本已删除')));
    popOrGoExplore(context);
  } else {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
  }
  return deleted;
}
