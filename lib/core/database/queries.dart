import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class CategoryAggregates {
  static getLevelDetails({
    @required List<Map<String, dynamic>> categoryHierarchy,
    int parentId = 0,
  }) {
    Map<int, Map<String, dynamic>> categoryParentDetails = {};

    int reqdLevel = 1;
    if (parentId != 0) {
      reqdLevel = categoryHierarchy.firstWhere(
            (v) => v['id'] == parentId,
            orElse: () => {'iLevel': 0},
          )['iLevel'] +
          1;
    }

    categoryHierarchy.map((v) {
      int currentId;
      String currentName;
      int currentParentId = parentId;

      if (v['id'] == parentId) {
        currentId = v['id'];
        currentName = v['categoryName'];

        // If current category is the parent category, get it's parent
        final int parentParentLevel = v['iLevel'] - 1;
        currentParentId = v['iTreeID$parentParentLevel'] ?? 0;
      } else if (currentParentId != 0 &&
          v['iTreeID${reqdLevel - 1}'] != currentParentId)
        return;
      else {
        currentId = v['iTreeID$reqdLevel'];
        currentName = v['iTree$reqdLevel'];
      }

      if (currentId == null) {
        if (v['id'] == currentParentId) {
          currentId = v['id'];
          currentName = v['categoryName'];
        } else
          return;
      }

      if (categoryParentDetails.containsKey(currentId)) {
        categoryParentDetails[currentId]['children']
            .add(v['${CategoryModel.colId}']);
      } else {
        categoryParentDetails[currentId] = {
          'parentId': currentParentId,
          'currentId': currentId,
          'currentName': currentName,
          'children': <int>[v['${CategoryModel.colId}']],
        };
      }
    }).toList();

    return categoryParentDetails;
  }
}

class Queries {
  static final log = Logger('Queries');
  static final dbProvider = DatabaseHelper.dbProvider;

  static Future<List<Map<String, dynamic>>> getCategoryAggregate({
    @required int startTime,
    @required int endTime,
    AccountMasterModel account,
    TransactionTypeModel txnType,
    @required List<Map<String, dynamic>> categoryHierarchy,
    int parentId = 0,
  }) async {
    if (categoryHierarchy == null || categoryHierarchy.isEmpty) {
      return Future.delayed(Duration(seconds: 0), () => []);
    }

    final db = await dbProvider.database;

    final categoryParentDetails = CategoryAggregates.getLevelDetails(
      categoryHierarchy: categoryHierarchy,
      parentId: parentId,
    );

    String groupCases = categoryParentDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN $k'))
        .values
        .join(' ');

    String selectCategoryNameCases = categoryParentDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN "${v['currentName']}"'))
        .values
        .join(' ');

    String selectParentCatIdCases = categoryParentDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN "${v['parentId']}"'))
        .values
        .join(' ');

    String selectCurrentIdCases = categoryParentDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN "${v['currentId']}"'))
        .values
        .join(' ');

    String selectChildrenCount = categoryParentDetails
        .map((k, v) => MapEntry(k,
            'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN ${v['children'].length - 1}'))
        .values
        .join(' ');

    String categoryFilterQuery = categoryParentDetails
        .map((k, v) => MapEntry(k,
            't.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')})'))
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
        COALESCE(SUM(t.${TransactionModel.colDebitAmount}), 0.0) as debitAggregate
        , COALESCE(SUM(t.${TransactionModel.colCreditAmount}), 0.0) as creditAggregate
        , CASE $selectCategoryNameCases ELSE "Uncategorised" END as category
        , CASE $selectParentCatIdCases ELSE 0 END as parentId
        , CASE $selectCurrentIdCases ELSE 0 END as currentId
        , CASE $selectChildrenCount ELSE 0 END as childrenCount
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
      return await db.rawQuery(query);
    } catch (err) {
      log.severe(err);
      log.warning(categoryHierarchy);
      return Future.delayed(Duration(seconds: 0), () => []);
    }
  }
}
