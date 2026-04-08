class PaginatedData<T> {
  final List<T> items;
  final int count;
  final int pageSize;
  final int totalPages;
  final int currentPage;
  final bool? next;
  final bool? previous;

  PaginatedData({
    required this.items,
    required this.count,
    required this.pageSize,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
  });

  factory PaginatedData.empty() {
    return PaginatedData(
      items: [],
      count: 0,
      pageSize: 20,
      totalPages: 0,
      currentPage: 1,
      next: false,
      previous: false,
    );
  }

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return PaginatedData(
      items: (json['items'] as List).map((e) => mapper(e)).toList(),
      count: json['count'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      next: json['next'] as bool?,
      previous: json['previous'] as bool?,
    );
  }

  PaginatedData<T> copyWith({
    List<T>? items,
    int? count,
    int? pageSize,
    int? totalPages,
    int? currentPage,
    bool? next,
    bool? previous,
  }) {
    return PaginatedData(
      items: items ?? this.items,
      count: count ?? this.count,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      next: next ?? this.next,
      previous: previous ?? this.previous,
    );
  }
}
