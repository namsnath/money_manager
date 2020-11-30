import 'package:equatable/equatable.dart';

class CategoryHierarchyModel with EquatableMixin {
  final int id;
  final int parentId;
  final int transactionTypeId;
  final String transactionType;
  final String category;
  final String categoryDisplayName;

  final int iLevel;
  final int iChildren;

  final List<int> iTreeID;
  final List<String> iTree;

  const CategoryHierarchyModel({
    this.id,
    this.parentId,
    this.transactionTypeId,
    this.transactionType,
    this.category,
    this.categoryDisplayName,
    this.iLevel,
    this.iChildren,
    this.iTreeID,
    this.iTree,
  });

  factory CategoryHierarchyModel.fromDatabaseJson(Map<String, dynamic> data) {
    final categoryNames = <String>[
      data['iTree1'],
      data['iTree2'],
      data['iTree3'],
      data['iTree4'],
      data['iTree5'],
      data['iTree6'],
      data['iTree7'],
      data['iTree8'],
      data['iTree9'],
      data['iTree10']
    ];

    // Get a human-friendly String for the whole category hierarchy for the current category
    String categoryDisplayName =
        categoryNames.where((v) => v != null && v != '').toList().join(':');

    return CategoryHierarchyModel(
      id: data['id'],
      parentId: data['parentId'],
      transactionTypeId: data['transactionTypeId'],
      transactionType: data['transactionType'],
      category: data['categoryName'],
      categoryDisplayName: categoryDisplayName,
      iLevel: data['iLevel'],
      iChildren: data['iChildren'],
      iTreeID: <int>[
        data['iTreeID1'],
        data['iTreeID2'],
        data['iTreeID3'],
        data['iTreeID4'],
        data['iTreeID5'],
        data['iTreeID6'],
        data['iTreeID7'],
        data['iTreeID8'],
        data['iTreeID9'],
        data['iTreeID10']
      ],
      iTree: categoryNames,
    );
  }

  // Map<String, dynamic> toDatabaseJson() => {
  //       colId: this.id,
  //       colTransactionType: this.transactionType,
  //     };

  @override
  List<Object> get props => [id];
}
