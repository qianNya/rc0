abstract interface class ImageFavoriteStore {
  static ImageFavoriteStore? instance;

  bool isFavorite(String id);

  Future<bool> toggle({
    required String id,
    required String imagePath,
    String? caption,
    String? sourceLabel,
  });

  Future<void> remove(String id);
}
