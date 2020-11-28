import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';
import 'package:money_manager/core/utils/datetime_util.dart';

class TransactionProvider extends ChangeNotifier {
  final log = Logger('TransactionProvider');
  final dbProvider = DatabaseHelper.dbProvider;

  List<TransactionModel> _transactionList = [];
  List<TransactionModel> get transactionList => _transactionList;

  String getAggregateQuery(
      int startTime, int endTime, AccountMasterModel account) {
    final baseQuery = """
      SELECT
        COALESCE(SUM(${TransactionModel.colDebitAmount}), 0.0) as debitAggregate
        , COALESCE(SUM(${TransactionModel.colCreditAmount}), 0.0) as creditAggregate
      FROM ${TransactionModel.tableName}
      WHERE
        ${TransactionModel.colTransactionTime} >= $startTime
        AND ${TransactionModel.colTransactionTime} <= $endTime
    """;

    if (account == null) {
      return baseQuery;
    } else {
      final accountFilterQuery =
          'AND ${TransactionModel.colFkAccountId} = ${account.id}';

      return baseQuery + accountFilterQuery;
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryAggregate({
    @required int startTime,
    @required int endTime,
    AccountMasterModel account,
    TransactionTypeModel txnType,
    @required List<Map<String, dynamic>> categoryHierarchy,
  }) async {
    if (categoryHierarchy == null || categoryHierarchy.isEmpty) {
      return Future.delayed(Duration(seconds: 0), () => []);
    }

    final db = await dbProvider.database;

    Map<int, Map<String, dynamic>> categoryParentDetails = {};

    categoryHierarchy.map((v) {
      final int parentId = v['iTreeID1'];
      final String parentName = v['iTree1'];

      if (categoryParentDetails.containsKey(parentId)) {
        categoryParentDetails[parentId]['children']
            .add(v['${CategoryModel.colId}']);
      } else {
        categoryParentDetails[parentId] = {
          'children': <int>[v['${CategoryModel.colId}']],
          'parentName': parentName,
        };
      }
    }).toList();

    String groupCases = categoryParentDetails
        .map((k, v) {
          return MapEntry(k,
              'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN $k');
        })
        .values
        .join(' ');

    String selectCategoryCases = categoryParentDetails
        .map((k, v) {
          return MapEntry(k,
              'WHEN t.${TransactionModel.colFkCategoryId} IN (${v['children'].join(',')}) THEN "${v['parentName']}"');
        })
        .values
        .join(' ');

    String accountFilterQuery = '';
    if (account != null) {
      accountFilterQuery =
          'AND ${TransactionModel.colFkAccountId} = ${account.id}';
    }

    final query = """
      SELECT
        COALESCE(SUM(t.${TransactionModel.colDebitAmount}), 0.0) as debitAggregate
        , COALESCE(SUM(t.${TransactionModel.colCreditAmount}), 0.0) as creditAggregate
        , COALESCE(CASE $selectCategoryCases END, "Uncategorised") as category
      FROM ${TransactionModel.tableName} t
      LEFT JOIN ${CategoryModel.tableName} c
        ON t.${TransactionModel.colFkCategoryId} = c.${CategoryModel.colId}
      WHERE
        t.${TransactionModel.colTransactionTime} >= $startTime
        AND t.${TransactionModel.colTransactionTime} <= $endTime
        AND t.${TransactionModel.colFkTransactionTypeId} = ${txnType?.id ?? 2}
        $accountFilterQuery
      GROUP BY CASE $groupCases ELSE 0 END
    """;

    try {
      return await db.rawQuery(query);
    } catch (err) {
      log.severe(err);
      log.warning(categoryHierarchy);
      return Future.delayed(Duration(seconds: 0), () => []);
    }
  }

  TransactionProvider() {
    // Initialise the state on Provider initialization
  }

  Future<Map<String, Map<String, double>>> getAggregates(
      {DateTime date, AccountMasterModel account}) async {
    final db = await dbProvider.database;

    if (date == null) {
      date = DateTime.now();
    }
    Map<String, Map<String, double>> aggregate = {
      'debit': {
        'day': 0.0,
        'week': 0.0,
        'month': 0.0,
        'year': 0.0,
      },
      'credit': {
        'day': 0.0,
        'week': 0.0,
        'month': 0.0,
        'year': 0.0,
      },
      'balance': {
        'day': 0.0,
        'week': 0.0,
        'month': 0.0,
        'year': 0.0,
      },
    };

    List<Map<String, dynamic>> dayAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfDay(date).millisecondsSinceEpoch,
        DateTimeUtil.endOfDay(date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['day'] = dayAggregate[0]['creditAggregate'];
    aggregate['debit']['day'] = dayAggregate[0]['debitAggregate'];
    aggregate['balance']['day'] =
        aggregate['credit']['day'] - aggregate['debit']['day'];

    List<Map<String, dynamic>> weekAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfWeek(date).millisecondsSinceEpoch,
        DateTimeUtil.endOfWeek(date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['week'] = weekAggregate[0]['creditAggregate'];
    aggregate['debit']['week'] = weekAggregate[0]['debitAggregate'];
    aggregate['balance']['week'] =
        aggregate['credit']['week'] - aggregate['debit']['week'];

    List<Map<String, dynamic>> monthAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfMonth(date).millisecondsSinceEpoch,
        DateTimeUtil.endOfMonth(date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['month'] = monthAggregate[0]['creditAggregate'];
    aggregate['debit']['month'] = monthAggregate[0]['debitAggregate'];
    aggregate['balance']['month'] =
        aggregate['credit']['month'] - aggregate['debit']['month'];

    List<Map<String, dynamic>> yearAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfYear(date).millisecondsSinceEpoch,
        DateTimeUtil.endOfYear(date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['year'] = yearAggregate[0]['creditAggregate'];
    aggregate['debit']['year'] = yearAggregate[0]['debitAggregate'];
    aggregate['balance']['year'] =
        aggregate['credit']['year'] - aggregate['debit']['year'];

    return aggregate;
  }

  Future<List<TransactionModel>> getTransactions(
      {List<String> columns = TransactionModel.columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;

    if (query != null && query.isNotEmpty) {
      result = await db.query(TransactionModel.tableName,
          columns: columns,
          where: 'description LIKE ?',
          whereArgs: ["%$query%"]);
    } else {
      result = await db.query(TransactionModel.tableName, columns: columns);
    }

    List<TransactionModel> txns = result.isNotEmpty
        ? result.map((item) => TransactionModel.fromDatabaseJson(item)).toList()
        : [];

    this._transactionList = txns;

    notifyListeners();

    return txns;
  }

  Future<int> addTransaction(TransactionModel txn) async {
    final db = await dbProvider.database;
    var result =
        await db.insert(TransactionModel.tableName, txn.toDatabaseJson());

    notifyListeners();

    return result;
  }

  Future<int> updateTransaction(TransactionModel txn) async {
    final db = await dbProvider.database;

    var result = await db.update(
        TransactionModel.tableName, txn.toDatabaseJson(),
        where: '${TransactionModel.colId} = ?', whereArgs: [txn.id]);

    notifyListeners();

    return result;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbProvider.database;

    var result = await db
        .delete(TransactionModel.tableName, where: 'id = ?', whereArgs: [id]);

    notifyListeners();

    return result;
  }
}
