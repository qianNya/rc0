class FavoriteImageItem {
  const FavoriteImageItem({
    required this.id,
    required this.imagePath,
    this.caption,
    this.sourceLabel,
    required this.savedAt,
  });

  final String id;
  final String imagePath;
  final String? caption;
  final String? sourceLabel;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        if (caption != null) 'caption': caption,
        if (sourceLabel != null) 'sourceLabel': sourceLabel,
        'savedAt': savedAt.toIso8601String(),
      };

  factory FavoriteImageItem.fromJson(Map<String, dynamic> json) {
    return FavoriteImageItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      caption: json['caption'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
