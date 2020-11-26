import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/account_type_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class DatabaseHelper {
  final log = Logger('DatabaseProvider');
  static final DatabaseHelper dbProvider = DatabaseHelper();

  static const databaseFileName = 'MoneyThingy.db';

  Database _db;

  Future<Database> get database async {
    if (_db != null) return _db;

    _db = await init();
    return _db;
  }

  init() async {
    // final dbDirectory = await getDatabasesPath();
    final dbDirectory = await getExternalStorageDirectory();
    log.info('Database path: ${dbDirectory.path}');

    Database _db = await openDatabase(join(dbDirectory.path, databaseFileName),
        version: 1, onCreate: _createDatabase, onUpgrade: _onUpgrade);

    log.info('Initialised Database');
    return _db;
  }

  void _createDatabase(Database database, int version) async {
    // Table Creation
    await database.execute(TransactionTypeModel.tableCreateQuery);
    await database.execute(AccountTypeModel.tableCreateQuery);
    await database.execute(AccountMasterModel.tableCreateQuery);
    await database.execute(CategoryModel.tableCreateQuery);
    await database.execute(TransactionModel.tableCreateQuery);

    // Initial Value Population
    await database.execute(AccountMasterModel.initialiseValuesQuery);
    await database.execute(TransactionTypeModel.initialiseValuesQuery);
    await database.execute(CategoryModel.initialiseValuesQuery);
    log.info('Created Database');
  }

  void _onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {
      // Do something
    }
  }
}
