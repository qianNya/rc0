import '../../screenplay/data/screenplay-api.dart' as sp_dto;

class ListFeedResp {
  ListFeedResp({required this.items, required this.total});

  final List<sp_dto.FeedItemDto> items;
  final num total;

  factory ListFeedResp.fromJson(Map<String, dynamic> m) {
    final raw = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListFeedResp(
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(sp_dto.FeedItemDto.fromJson)
          .toList(),
      total: m['total'] ?? 0,
    );
  }
}

class SearchResultItem {
  SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String type;
  final num id;
  final String title;
  final String subtitle;

  factory SearchResultItem.fromJson(Map<String, dynamic> m) {
    return SearchResultItem(
      type: m['type'] ?? '',
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      subtitle: m['subtitle'] ?? m['summary'] ?? '',
    );
  }
}

class SearchResp {
  SearchResp({required this.list, required this.total});

  final List<SearchResultItem> list;
  final num total;

  factory SearchResp.fromJson(Map<String, dynamic> m) {
    return SearchResp(
      list: ((m['list'] ?? m['items'] ?? []) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SearchResultItem.fromJson)
          .toList(),
      total: m['total'] ?? 0,
    );
  }
}
