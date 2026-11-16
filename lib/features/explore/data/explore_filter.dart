enum PostSort { newest, mostSaved, shortest }

class ExploreFilter {
  const ExploreFilter({
    this.query = '',
    this.maxDuration,
    this.categoryId,
    this.sort = PostSort.newest,
  });

  final String query;
  final int? maxDuration;
  final int? categoryId;
  final PostSort sort;
}
