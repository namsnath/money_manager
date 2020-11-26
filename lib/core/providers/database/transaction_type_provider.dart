import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class TransactionTypeProvider extends ChangeNotifier {
  final log = Logger('TransactionTypeProvider');
  final dbProvider = DatabaseHelper.dbProvider;

  static const _formTransactionTypeIds = [1, 2, 3];

  List<TransactionTypeModel> _transactionTypeList = [];
  List<TransactionTypeModel> get transactionTypeList => _transactionTypeList;

  List<TransactionTypeModel> _formTransactionTypeList = [];
  List<TransactionTypeModel> get formTransactionTypeList =>
      _formTransactionTypeList;

  TransactionTypeProvider() {
    // Initialise the state on Provider initialization
    getTransactionTypes();
  }

  Future<List<TransactionTypeModel>> getTransactionTypes(
      {List<String> columns = TransactionTypeModel.columns,
      String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;

    if (query != null && query.isNotEmpty) {
      result = await db.query(TransactionTypeModel.tableName,
          columns: columns,
          where: 'description LIKE ?',
          whereArgs: ["%$query%"]);
    } else {
      result = await db.query(TransactionTypeModel.tableName, columns: columns);
    }

    List<TransactionTypeModel> transactionTypes = result.isNotEmpty
        ? result
            .map((item) => TransactionTypeModel.fromDatabaseJson(item))
            .toList()
        : [];

    this._transactionTypeList = transactionTypes;
    this._formTransactionTypeList = transactionTypes
        .where((t) => _formTransactionTypeIds.contains(t.id))
        .toList();

    notifyListeners();

    return transactionTypes;
  }
}
