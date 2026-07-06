/// Three-tier zoom navigation for the cabinet system.
enum GearZoomLevel {
  /// Multiple cabinet thumbnails.
  overview,

  /// Single cabinet with all shelves expanded.
  focus,

  /// Single device full-screen detail (handled by route overlay).
  detail,
}
