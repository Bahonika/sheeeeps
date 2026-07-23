/// Non-web fallback for [NameStore]: nothing to persist to (desktop keeps the
/// name only for the running session).
class NameStore {
  String? load() => null;
  void save(String name) {}
}
