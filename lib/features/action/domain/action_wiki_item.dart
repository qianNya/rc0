/// Static action wiki entry (pose / movement / framing reference).
class ActionWikiItem {
  const ActionWikiItem({
    required this.id,
    required this.label,
    required this.group,
  });

  final String id;
  final String label;
  final String group;
}

List<ActionWikiItem> buildActionWikiItems() {
  const groups = <String, List<String>>{
    '景别': ['全景', '中景', '近景', '特写', '大特写'],
    '运镜': ['固定', '推', '拉', '摇', '移', '跟', '升降'],
    '机位': ['平视', '俯拍', '仰拍', '鸟瞰', '虫视'],
    '构图': ['三分法', '居中', '对称', '引导线', '框架'],
  };

  final items = <ActionWikiItem>[];
  for (final entry in groups.entries) {
    for (final label in entry.value) {
      items.add(
        ActionWikiItem(
          id: '${entry.key}-$label',
          label: label,
          group: entry.key,
        ),
      );
    }
  }
  return items;
}

const actionWikiGroups = ['全部', '景别', '运镜', '机位', '构图'];
