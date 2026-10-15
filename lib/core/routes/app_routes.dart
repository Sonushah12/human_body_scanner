abstract final class AppRoutes {
  static const explore = '/explore';
  static const bookmarks = '/bookmarks';
  static const quiz = '/quiz';
  static const settings = '/settings';
  static const credits = '/credits';
  static const detail = '/part/:id';
  static String part(String id) => '/part/${Uri.encodeComponent(id)}';
}
