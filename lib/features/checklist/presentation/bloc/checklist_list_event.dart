abstract class ChecklistListEvent {
  const ChecklistListEvent();
}

class LoadChecklistList extends ChecklistListEvent {
  final String keyword;
  final int page;
  final int perPage;

  const LoadChecklistList({
    this.keyword = '',
    this.page = 1,
    this.perPage = 1073741824,
  });
}
