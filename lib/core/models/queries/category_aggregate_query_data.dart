import 'package:equatable/equatable.dart';

class CategoryAggregateQueryData with EquatableMixin {
  final double creditSum;
  final double debitSum;
  final String category;
  final int parentId;
  final int currentId;
  final int childrenCount;

  CategoryAggregateQueryData({
    this.creditSum,
    this.debitSum,
    this.category,
    this.parentId,
    this.currentId,
    this.childrenCount,
  });

  factory CategoryAggregateQueryData.fromDatabaseJson(Map<String, dynamic> data) {
    return CategoryAggregateQueryData(
      creditSum: data['creditSum'],
      debitSum: data['debitSum'],
      category: data['category'],
      parentId: data['parentId'],
      currentId: data['currentId'],
      childrenCount: data['childrenCount'],
    );
  }

  @override
  List<Object> get props => [currentId, parentId];
}
