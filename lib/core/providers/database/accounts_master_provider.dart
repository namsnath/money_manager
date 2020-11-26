import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';

class AccountsMasterProvider extends ChangeNotifier {
  final log = Logger('AccountsMasterProvider');
  final dbProvider = DatabaseHelper.dbProvider;

  List<AccountMasterModel> _accountsList = [];
  List<AccountMasterModel> get accountsList => _accountsList;

  AccountsMasterProvider() {
    // Initialise the state on Provider initialization
    getAccounts();
  }

  Future<List<AccountMasterModel>> getAccounts(
      {List<String> columns = AccountMasterModel.columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;

    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(AccountMasterModel.tableName,
            columns: columns,
            where: 'description LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db.query(AccountMasterModel.tableName, columns: columns);
    }

    List<AccountMasterModel> accounts = result.isNotEmpty
        ? result.map((item) => AccountMasterModel.fromDatabaseJson(item)).toList()
        : [];

    this._accountsList = accounts;

    notifyListeners();

    return accounts;
  }

  Future<int> addAccount(AccountMasterModel account) async {
    final db = await dbProvider.database;
    var result =
        await db.insert(AccountMasterModel.tableName, account.toDatabaseJson());

    this._accountsList = await getAccounts();

    return result;
  }

  Future<int> updateAccount(AccountMasterModel account) async {
    final db = await dbProvider.database;

    var result = await db.update(
        AccountMasterModel.tableName, account.toDatabaseJson(),
        where: '${AccountMasterModel.colId} = ?', whereArgs: [account.id]);

    this._accountsList = await getAccounts();

    return result;
  }

  Future<int> deleteAccount(int id) async {
    final db = await dbProvider.database;

    var result = await db
        .delete(AccountMasterModel.tableName, where: 'id = ?', whereArgs: [id]);

    this._accountsList = await getAccounts();

    return result;
  }
}
