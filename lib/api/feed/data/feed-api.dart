import '../../screenplay/data/screenplay-api.dart';

class FeedItem {
  final Screenplay screenplay;
  final String itemType;
  final String authorNickname;

  FeedItem({
    required this.screenplay,
    required this.itemType,
    required this.authorNickname,
  });

  factory FeedItem.fromJson(Map<String, dynamic> m) {
    final spMap = m['screenplay'];
    final author = m['author'];
    return FeedItem(
      screenplay: spMap is Map<String, dynamic>
          ? Screenplay.fromJson(spMap)
          : Screenplay.fromJson(m),
      itemType: m['item_type'] ?? m['type'] ?? 'screenplay',
      authorNickname: author is Map<String, dynamic>
          ? (author['nickname'] ?? author['username'] ?? '')
          : (m['author_nickname'] ?? ''),
    );
  }
}

class ListFeedResp {
  final List<FeedItem> list;
  final num total;

  ListFeedResp({required this.list, required this.total});

  factory ListFeedResp.fromJson(Map<String, dynamic> m) {
    return ListFeedResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => FeedItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
}

class SearchResultItem {
  final String type;
  final num id;
  final String title;
  final String subtitle;

  SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
  });

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
  final List<SearchResultItem> list;
  final num total;

  SearchResp({required this.list, required this.total});

  factory SearchResp.fromJson(Map<String, dynamic> m) {
    return SearchResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => SearchResultItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
}
