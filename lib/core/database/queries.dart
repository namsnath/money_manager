import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';
import 'package:money_manager/core/models/queries/category_aggregate_query_data.dart';
import 'package:money_manager/core/models/queries/category_hierarchy_model.dart';
import 'package:money_manager/core/models/queries/category_level_data.dart';

class CategoryAggregates {
  /// Gets children data from the given [categoryHierarchy] and [parentId].
  ///
  /// [categoryHierarchy] is usually from [CategoryProvider.categoryHierarchy].
  /// [parentId] is the highest-level parent to use for getting details.
  /// Categories outside of this tree will be ignored. Defaults to 0.
  ///
  /// [CategoryLevelData.children] includes the parent and all its children.
  static Map<int, CategoryLevelData> getLevelDetails({
    @required List<CategoryHierarchyModel> categoryHierarchy,
    int parentId = 0,
  }) {
    Map<int, CategoryLevelData> categoryLevelDetails = {};

    // Reqd Level would be the first one by default (no parent).
    int reqdLevel = 0;

    // If parent is not 0, it has a valid parent.
    if (parentId != 0) {
      // Find the parent category.
      final reqdItem = categoryHierarchy.firstWhere(
        (v) => v.id == parentId,
        // Return a placeholder with iLevel = 1.
        orElse: () => CategoryHierarchyModel(iLevel: 1),
      );

      // Required level is the iLevel of the parent.
      reqdLevel = reqdItem.iLevel;
    }

    categoryHierarchy.map((v) {
      int currentId;
      String currentName;
      int currentParentId = parentId;

      // If the current category is the parent.
      if (v.id == parentId) {
        currentId = v.id;
        currentName = v.category;

        // If current category is the parent category, get it's parent.
        final int parentParentLevel = v.iLevel;
        currentParentId = v.iTreeID[parentParentLevel] ?? 0;
      } else if (currentParentId != 0 &&
          v.iTreeID[reqdLevel - 1] != currentParentId) {
        // The category does not belong under the current parent.
        // Parent id not 0 => Not top-level, and has a parent (so that next condition doesnt error).
        // iTreeID[reqdLevel - 1] not equal to parentID => does not belong in this tree.
        return;
      } else {
        // Category is a valid child.
        // Get appropriate data.
        currentId = v.iTreeID[reqdLevel];
        currentName = v.iTree[reqdLevel];
      }

      // If the currentId exists in the map, add currentId to it's children.
      if (categoryLevelDetails.containsKey(currentId)) {
        categoryLevelDetails[currentId].children.add(v.id);
      } else {
        // If currentId not present, initialise the data.
        categoryLevelDetails[currentId] = CategoryLevelData(
          parentId: currentParentId,
          currentId: currentId,
          currentName: currentName,
          children: <int>[v.id],
        );
      }
    }).toList();

    return categoryLevelDetails;
  }
}

class Queries {
  static final log = Logger('Queries');
  static final dbProvider = DatabaseHelper.dbProvider;

  static Future<List<CategoryAggregateQueryData>> getCategoryAggregate({
    @required int startTime,
    @required int endTime,
    AccountMasterModel account,
    TransactionTypeModel txnType,
    @required List<CategoryHierarchyModel> categoryHierarchy,
    int parentId = 0,
  }) async {
    if (categoryHierarchy == null || categoryHierarchy.isEmpty) {
      return Future.delayed(Duration(seconds: 0), () => []);
    }

    final db = await dbProvider.database;

    final categoryLevelDetails = CategoryAggregates.getLevelDetails(
      categoryHierarchy: categoryHierarchy,
      parentId: parentId,
    );

    String groupCases = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')}) THEN $k'))
        .values
        .join(' ');

    String selectCategoryNameCases = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')}) THEN "${v.currentName}"'))
        .values
        .join(' ');

    String selectParentCatIdCases = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')}) THEN "${v.parentId}"'))
        .values
        .join(' ');

    String selectCurrentIdCases = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')}) THEN "${v.currentId}"'))
        .values
        .join(' ');

    String selectChildrenCount = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')}) THEN ${v.children.length - 1}'))
        .values
        .join(' ');

    String categoryFilterQuery = categoryLevelDetails
        .map((k, v) => MapEntry(k,
            't.${TransactionModel.colFkCategoryId} IN (${v.children.join(',')})'))
        .values
        .join(' OR ');

    String accountFilterQuery = '';
    if (account != null) {
      accountFilterQuery =
          'AND ${TransactionModel.colFkAccountId} = ${account.id}';
    }

    String uncategorisedFilterQuery = '';
    if (parentId == 0) {
      uncategorisedFilterQuery = 'OR t.${TransactionModel.colFkCategoryId} = 0';
    }

    final query = """
      SELECT
        COALESCE(SUM(t.${TransactionModel.colDebitAmount}), 0.0) as debitSum
        , COALESCE(SUM(t.${TransactionModel.colCreditAmount}), 0.0) as creditSum
        , CAST(CASE $selectCategoryNameCases ELSE "Uncategorised" END AS TEXT) as category
        , CAST(CASE $selectParentCatIdCases ELSE 0 END AS INTEGER) as parentId
        , CAST(CASE $selectCurrentIdCases ELSE 0 END AS INTEGER) as currentId
        , CAST(CASE $selectChildrenCount ELSE 0 END AS INTEGER) as childrenCount
      FROM ${TransactionModel.tableName} t
      LEFT JOIN ${CategoryModel.tableName} c
        ON t.${TransactionModel.colFkCategoryId} = c.${CategoryModel.colId}
      WHERE
        t.${TransactionModel.colFkTransactionTypeId} = ${txnType?.id ?? 2}
        AND t.${TransactionModel.colTransactionTime} >= $startTime
        AND t.${TransactionModel.colTransactionTime} <= $endTime
        AND ($categoryFilterQuery $uncategorisedFilterQuery)
        $accountFilterQuery
      GROUP BY (CASE $groupCases ELSE 0 END)
    """;

    try {
      final results = await db.rawQuery(query);
      return results.map((item) => CategoryAggregateQueryData.fromDatabaseJson(item)).toList();
    } catch (err) {
      log.severe(err);
      log.warning(categoryHierarchy);
      return Future.delayed(Duration(seconds: 0), () => []);
    }
  }
}
