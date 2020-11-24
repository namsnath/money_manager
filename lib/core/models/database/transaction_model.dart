import 'package:equatable/equatable.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class TransactionModel with EquatableMixin {
  static const tableName = 'transactions';

  static const colId = 'id';
  static const colFkAccountId = 'fk_account_id';
  static const colFkTransactionTypeId = 'fk_transaction_type_id';
  static const colFkCategoryId = 'fk_category_id';

  static const colTransactionTime = 'transaction_time';
  static const colModifiedTime = 'modified_time';
  static const colDebitAmount = 'debit_amount';
  static const colCreditAmount = 'credit_amount';
  static const colDescription = 'description';

  static const columns = [
    colId,
    colFkAccountId,
    colFkTransactionTypeId,
    colFkCategoryId,
    colTransactionTime,
    colModifiedTime,
    colDebitAmount,
    colCreditAmount,
    colDescription,
  ];

  static const tableCreateQuery = 'CREATE TABLE $tableName ('
      '$colId INTEGER PRIMARY KEY, '
      '$colFkAccountId INTEGER DEFAULT 0, '
      '$colFkTransactionTypeId INTEGER DEFAULT 0, '
      '$colFkCategoryId INTEGER DEFAULT 0, '
      '$colTransactionTime INTEGER, '
      '$colModifiedTime INTEGER, '
      '$colDebitAmount REAL, '
      '$colCreditAmount REAL, '
      '$colDescription TEXT, '
      'FOREIGN KEY ($colFkAccountId) REFERENCES ${AccountMasterModel.tableName} (${AccountMasterModel.colId}) ON DELETE SET DEFAULT ON UPDATE CASCADE, '
      'FOREIGN KEY ($colFkTransactionTypeId) REFERENCES ${TransactionTypeModel.tableName} (${TransactionTypeModel.colId}) ON DELETE SET DEFAULT ON UPDATE CASCADE, '
      'FOREIGN KEY ($colFkCategoryId) REFERENCES ${CategoryModel.tableName} (${CategoryModel.colId}) ON DELETE SET DEFAULT ON UPDATE CASCADE'
      ')';

  final int id;
  final int fkAccountId;
  final int fkTransactionTypeId;
  final int fkCategoryId;

  final int transactionTime;
  final int modifiedTime;
  final double debitAmount;
  final double creditAmount;
  final String description;

  TransactionModel(
      {this.id,
      this.fkAccountId,
      this.fkTransactionTypeId,
      this.fkCategoryId,
      this.transactionTime,
      this.modifiedTime,
      this.debitAmount,
      this.creditAmount,
      this.description});

  factory TransactionModel.fromDatabaseJson(Map<String, dynamic> data) {
    return TransactionModel(
      id: data[colId],
      fkAccountId: data[colFkAccountId],
      fkTransactionTypeId: data[colFkTransactionTypeId],
      fkCategoryId: data[colFkCategoryId],
      transactionTime: data[colTransactionTime],
      modifiedTime: data[colModifiedTime],
      debitAmount: data[colDebitAmount],
      creditAmount: data[colCreditAmount],
      description: data[colDescription],
    );
  }

  Map<String, dynamic> toDatabaseJson() => {
        colId: this.id,
        colFkAccountId: this.fkAccountId,
        colFkTransactionTypeId: this.fkTransactionTypeId,
        colFkCategoryId: this.fkCategoryId,
        colTransactionTime: this.transactionTime,
        colModifiedTime: this.modifiedTime,
        colDebitAmount: this.debitAmount,
        colCreditAmount: this.creditAmount,
        colDescription: this.description,
      };

  // Equatable
  @override
  List<Object> get props => [id];
}
