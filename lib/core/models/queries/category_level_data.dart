import 'package:equatable/equatable.dart';

class CategoryLevelData with EquatableMixin {
  final int parentId;
  final int currentId;
  final String currentName;
  final List<int> children;

  CategoryLevelData({
    this.parentId,
    this.currentId,
    this.currentName,
    this.children,
  });

  @override
  List<Object> get props => [parentId, currentId];
}
