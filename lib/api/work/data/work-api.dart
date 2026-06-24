class WorkItem {
  final num id;
  final String title;
  final num workType;
  final num releaseYear;
  final String summary;

  WorkItem({
    required this.id,
    required this.title,
    required this.workType,
    required this.releaseYear,
    required this.summary,
  });

  factory WorkItem.fromJson(Map<String, dynamic> m) {
    return WorkItem(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      workType: m['work_type'] ?? 0,
      releaseYear: m['release_year'] ?? 0,
      summary: m['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'work_type': workType,
        'release_year': releaseYear,
        'summary': summary,
      };
}

class ListWorksResp {
  final List<WorkItem> list;
  final num total;
  final num page;
  final num pageSize;

  ListWorksResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ListWorksResp.fromJson(Map<String, dynamic> m) {
    final raw = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListWorksResp(
      list: raw
          .whereType<Map<String, dynamic>>()
          .map(WorkItem.fromJson)
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

class WorkWriteBody {
  const WorkWriteBody({
    required this.title,
    required this.workType,
    required this.releaseYear,
    required this.summary,
  });

  final String title;
  final int workType;
  final int releaseYear;
  final String summary;

  Map<String, dynamic> toJson() => {
        'title': title,
        'work_type': workType,
        'release_year': releaseYear,
        'summary': summary,
      };
}
