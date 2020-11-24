import 'package:equatable/equatable.dart';
import 'package:money_manager/core/constants/initial_categories.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class CategoryModel with EquatableMixin {
  static const tableName = 'categories';

  static const colId = 'id';
  static const colFkSelfParentId = 'fk_parent_id';
  static const colFkTransactionTypeId = 'fk_transaction_type_id';
  static const colCategory = 'category';

  static const columns = [
    colId,
    colFkSelfParentId,
    colFkTransactionTypeId,
    colCategory
  ];
  static final columnsString = columns.join(',');

  static const tableCreateQuery = 'CREATE TABLE $tableName ('
      '$colId INTEGER PRIMARY KEY, '
      '$colFkSelfParentId INTEGER DEFAULT 0, '
      '$colFkTransactionTypeId INTEGER DEFAULT 0, '
      '$colCategory TEXT, '
      'FOREIGN KEY ($colFkSelfParentId) REFERENCES $tableName ($colId) ON DELETE SET DEFAULT ON UPDATE CASCADE, '
      'FOREIGN KEY ($colFkTransactionTypeId) REFERENCES ${TransactionTypeModel.tableName} (${TransactionTypeModel.colId}) ON DELETE SET DEFAULT ON UPDATE CASCADE'
      ')';

  static final initialiseValuesQuery =
      'INSERT INTO $tableName ($columnsString) VALUES ${InitialCategories.data}';

  final int id;
  final int fkSelfParentId;
  final int fkTransactionTypeId;
  final String category;

  CategoryModel(
      {this.id, this.fkSelfParentId, this.fkTransactionTypeId, this.category});

  factory CategoryModel.fromDatabaseJson(Map<String, dynamic> data) {
    return CategoryModel(
      id: data[colId],
      fkSelfParentId: data[colFkSelfParentId],
      fkTransactionTypeId: data[colFkTransactionTypeId],
      category: data[colCategory],
    );
  }

  Map<String, dynamic> toDatabaseJson() => {
        colId: this.id,
        colFkSelfParentId: this.fkSelfParentId,
        colFkTransactionTypeId: this.fkTransactionTypeId,
        colCategory: this.category,
      };

  // Equatable
  @override
  List<Object> get props => [id];
}
