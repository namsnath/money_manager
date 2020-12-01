import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
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
        DateTimeUtil.startOfDay(date: date).millisecondsSinceEpoch,
        DateTimeUtil.endOfDay(date: date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['day'] = dayAggregate[0]['creditAggregate'];
    aggregate['debit']['day'] = dayAggregate[0]['debitAggregate'];
    aggregate['balance']['day'] =
        aggregate['credit']['day'] - aggregate['debit']['day'];

    List<Map<String, dynamic>> weekAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfWeek(date: date).millisecondsSinceEpoch,
        DateTimeUtil.endOfWeek(date: date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['week'] = weekAggregate[0]['creditAggregate'];
    aggregate['debit']['week'] = weekAggregate[0]['debitAggregate'];
    aggregate['balance']['week'] =
        aggregate['credit']['week'] - aggregate['debit']['week'];

    List<Map<String, dynamic>> monthAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfMonth(date: date).millisecondsSinceEpoch,
        DateTimeUtil.endOfMonth(date: date).millisecondsSinceEpoch,
        account,
      ),
    );
    aggregate['credit']['month'] = monthAggregate[0]['creditAggregate'];
    aggregate['debit']['month'] = monthAggregate[0]['debitAggregate'];
    aggregate['balance']['month'] =
        aggregate['credit']['month'] - aggregate['debit']['month'];

    List<Map<String, dynamic>> yearAggregate = await db.rawQuery(
      getAggregateQuery(
        DateTimeUtil.startOfYear(date: date).millisecondsSinceEpoch,
        DateTimeUtil.endOfYear(date: date).millisecondsSinceEpoch,
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
