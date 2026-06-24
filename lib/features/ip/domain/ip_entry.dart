/// IP reference entry from `GET /works` (anime / game / manga, etc.).
class IpEntry {
  const IpEntry({
    required this.id,
    required this.title,
    required this.workType,
    required this.releaseYear,
    required this.summary,
  });

  final int id;
  final String title;
  final int workType;
  final int releaseYear;
  final String summary;

  IpEntry copyWith({
    int? id,
    String? title,
    int? workType,
    int? releaseYear,
    String? summary,
  }) {
    return IpEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      workType: workType ?? this.workType,
      releaseYear: releaseYear ?? this.releaseYear,
      summary: summary ?? this.summary,
    );
  }
}
