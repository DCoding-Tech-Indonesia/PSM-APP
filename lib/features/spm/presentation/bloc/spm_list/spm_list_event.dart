abstract class SpmListEvent {
  const SpmListEvent();
}

class LoadSpmList extends SpmListEvent {
  final String keyword;
  final int page;
  final int perPage;

  const LoadSpmList({
    this.keyword = '',
    this.page = 1,
    this.perPage = 999,
  });
}
