import 'package:flutter/widgets.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';
import 'package:money_manager/core/models/queries/category_hierarchy_model.dart';

class CategoryProvider extends ChangeNotifier {
  final log = Logger('CategoryProvider');
  final dbProvider = DatabaseHelper.dbProvider;

  static int get defaultCategory => 0; // No Category

  String getHierarchyQuery() => """
  WITH RECURSIVE categoriesHierarchical(${CategoryModel.colId}, ${CategoryModel.colFkSelfParentId}, ${CategoryModel.colFkTransactionTypeId}, ${CategoryModel.colCategory}) AS
		(SELECT ${CategoryModel.tableName}.${CategoryModel.colId}
				, ${CategoryModel.tableName}.${CategoryModel.colFkSelfParentId}
        , ${CategoryModel.tableName}.${CategoryModel.colFkTransactionTypeId}
				, ${CategoryModel.tableName}.${CategoryModel.colCategory}
			FROM ${CategoryModel.tableName}
			ORDER BY ${CategoryModel.tableName}.${CategoryModel.colCategory})
		, CTE(${CategoryModel.colId}, ${CategoryModel.colFkSelfParentId}, ${CategoryModel.colFkTransactionTypeId}, ${CategoryModel.colCategory}, iLevel, iTreeID1, iTreeID2, iTreeID3, iTreeID4, iTreeID5, iTreeID6, iTreeID7, iTreeID8, iTreeID9, iTreeID10) AS
		(SELECT LevelThis.${CategoryModel.colId}
				, LevelThis.${CategoryModel.colFkSelfParentId}
        , LevelThis.${CategoryModel.colFkTransactionTypeId}
        , LevelThis.${CategoryModel.colCategory}
				, CAST(0 AS INTEGER)
				, LevelThis.${CategoryModel.colId}
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				, CAST(NULL AS INTEGER)
				
			FROM categoriesHierarchical LevelThis
			WHERE LevelThis.${CategoryModel.colFkSelfParentId} = 0
		UNION ALL
		SELECT LevelCurr.${CategoryModel.colId}
				, LevelCurr.${CategoryModel.colFkSelfParentId}
        , LevelCurr.${CategoryModel.colFkTransactionTypeId}
        , LevelCurr.${CategoryModel.colCategory}
				, LevelParent.iLevel + 1
				, LevelParent.iTreeID1
				, CASE WHEN LevelParent.iLevel = 0 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID2 END
				, CASE WHEN LevelParent.iLevel = 1 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID3 END
				, CASE WHEN LevelParent.iLevel = 2 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID4 END
				, CASE WHEN LevelParent.iLevel = 3 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID5 END
				, CASE WHEN LevelParent.iLevel = 4 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID6 END
				, CASE WHEN LevelParent.iLevel = 5 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID7 END
				, CASE WHEN LevelParent.iLevel = 6 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID8 END
				, CASE WHEN LevelParent.iLevel = 7 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID9 END
				, CASE WHEN LevelParent.iLevel = 8 THEN LevelCurr.${CategoryModel.colId} ELSE LevelParent.iTreeID10 END
				FROM CTE LevelParent
			JOIN categoriesHierarchical LevelCurr
				ON LevelParent.${CategoryModel.colId} = LevelCurr.${CategoryModel.colFkSelfParentId}
			WHERE LevelParent.iLevel < 10
                AND LevelCurr.${CategoryModel.colFkSelfParentId} > 0)

	SELECT CTE.${CategoryModel.colId} as id
			, CTE.${CategoryModel.colFkSelfParentId} as parentId
      , CTE.${CategoryModel.colFkTransactionTypeId} as transactionTypeId
      , t.${TransactionTypeModel.colTransactionType} as transactionType
      , CTE.${CategoryModel.colCategory} as categoryName
			, CAST(CTE.iLevel + 1 AS INTEGER) AS iLevel
			, CAST((SELECT COUNT(*) FROM ${CategoryModel.tableName} mA WHERE mA.${CategoryModel.colFkSelfParentId} = CTE.${CategoryModel.colId}) AS INTEGER) AS iChildren
      , CTE.iTreeID1
      , CTE.iTreeID2
      , CTE.iTreeID3
      , CTE.iTreeID4
      , CTE.iTreeID5
      , CTE.iTreeID6
      , CTE.iTreeID7
      , CTE.iTreeID8
      , CTE.iTreeID9
      , CTE.iTreeID10
      , c1.${CategoryModel.colCategory} as iTree1
      , c2.${CategoryModel.colCategory} as iTree2
      , c3.${CategoryModel.colCategory} as iTree3
      , c4.${CategoryModel.colCategory} as iTree4
      , c5.${CategoryModel.colCategory} as iTree5
      , c6.${CategoryModel.colCategory} as iTree6
      , c7.${CategoryModel.colCategory} as iTree7
      , c8.${CategoryModel.colCategory} as iTree8
      , c9.${CategoryModel.colCategory} as iTree9
      , c10.${CategoryModel.colCategory} as iTree10
		FROM CTE
			JOIN ${CategoryModel.tableName}
				ON CTE.${CategoryModel.colId} = ${CategoryModel.tableName}.${CategoryModel.colId}
      JOIN ${TransactionTypeModel.tableName} t
        ON CTE.${CategoryModel.colFkTransactionTypeId} = t.${TransactionTypeModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c1
        ON CTE.iTreeID1 = c1.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c2
        ON CTE.iTreeID2 = c2.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c3
        ON CTE.iTreeID3 = c3.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c4
        ON CTE.iTreeID4 = c4.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c5
        ON CTE.iTreeID5 = c5.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c6
        ON CTE.iTreeID6 = c6.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c7
        ON CTE.iTreeID7 = c7.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c8
        ON CTE.iTreeID8 = c8.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c9
        ON CTE.iTreeID9 = c9.${CategoryModel.colId}
      LEFT JOIN ${CategoryModel.tableName} c10
        ON CTE.iTreeID10 = c10.${CategoryModel.colId}
      ORDER BY iLevel ASC, categoryName ASC
  """;

  List<CategoryModel> _categoryList = [];
  List<CategoryModel> get categoryList => _categoryList;

  List<CategoryHierarchyModel> _categoryHierarchy = [];
  List<CategoryHierarchyModel> get categoryHierarchy => _categoryHierarchy;

  Map<int, String> _categoryHierarchyMap = {};
  Map<int, String> get categoryHierarchyMap => _categoryHierarchyMap;

  CategoryProvider() {
    // Initialise the state on Provider initialization
    getAllCategories();
  }

  Future getAllCategories() async {
    final db = await dbProvider.database;
    Map<int, String> categoryMap = {};

    List<Map<String, dynamic>> allCategoriesResult =
        await db.query(CategoryModel.tableName, columns: CategoryModel.columns);

    List<CategoryModel> accounts = allCategoriesResult.isNotEmpty
        ? allCategoriesResult
            .map((item) => CategoryModel.fromDatabaseJson(item))
            .toList()
        : [];

    List<Map<String, dynamic>> categoryHierarchyResult =
        await db.rawQuery(getHierarchyQuery());

    List<CategoryHierarchyModel> catHierarchy = categoryHierarchyResult.map(
      (item) {
        final obj = CategoryHierarchyModel.fromDatabaseJson(item);
        categoryMap[obj.id] = obj.categoryDisplayName;
        return obj;
      },
    ).toList();

    this._categoryList = accounts;
    this._categoryHierarchy = catHierarchy;
    this._categoryHierarchyMap = categoryMap;

    notifyListeners();
  }

  Future<List<CategoryModel>> getCategories(
      {List<String> columns = CategoryModel.columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;

    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(CategoryModel.tableName,
            columns: columns,
            where: 'description LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db.query(CategoryModel.tableName, columns: columns);
    }

    List<CategoryModel> accounts = result.isNotEmpty
        ? result.map((item) => CategoryModel.fromDatabaseJson(item)).toList()
        : [];

    this._categoryList = accounts;

    return accounts;
  }

  List<Node> getCategoryTree({int transactionTypeId: 1}) {
    List<Node> tree = [];

    for (int i = 0; i < _categoryHierarchy.length; i++) {
      var current = _categoryHierarchy[i];
      if (current.transactionTypeId != transactionTypeId) continue;

      var currentId = current.id;
      var level = current.iLevel;
      var categoryName = current.iTree[level - 1];

      var newNode = Node(
        label: categoryName,
        key: currentId.toString(),
        children: [],
      );

      if (level == 1) {
        tree.add(newNode);
      } else {
        // Find index in tree corresponding to key indicated for first level
        var index = tree
            .indexWhere((node) => node.key == current.iTreeID[0].toString());
        // Set parent node to found index
        var parentNode = tree[index];

        for (int j = 2; j < level; j++) {
          // Find index in children of Node for the key indicated in the Jth level
          var index = parentNode?.children?.indexWhere(
              (node) => node.key == current.iTreeID[j - 1].toString());
          // Set parent node to found index
          parentNode = parentNode?.children[index];
        }

        // In the resulting parent Node, add the new node
        parentNode?.children?.add(newNode);
      }
    }

    return tree;
  }

  Future<int> addCategory(CategoryModel account) async {
    final db = await dbProvider.database;
    var result =
        await db.insert(CategoryModel.tableName, account.toDatabaseJson());

    this._categoryList = await getAllCategories();

    return result;
  }

  Future<int> updateCategory(CategoryModel account) async {
    final db = await dbProvider.database;

    var result = await db.update(
        CategoryModel.tableName, account.toDatabaseJson(),
        where: '${CategoryModel.colId} = ?', whereArgs: [account.id]);

    this._categoryList = await getAllCategories();

    return result;
  }

  Future<int> deleteCategory(int id) async {
    final db = await dbProvider.database;

    var result = await db
        .delete(CategoryModel.tableName, where: 'id = ?', whereArgs: [id]);

    this._categoryList = await getAllCategories();

    return result;
  }
}
