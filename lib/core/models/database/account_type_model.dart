import 'package:equatable/equatable.dart';

class AccountTypeModel with EquatableMixin {
  static const tableName = 'account_types';

  static const colId = 'id';
  static const colAccountType = 'account_type';

  static const tableCreateQuery = 'CREATE TABLE $tableName ('
      '$colId INTEGER PRIMARY KEY, '
      '$colAccountType TEXT'
      ')';

  static const columns = [colId, colAccountType];

  final int id;
  final String accountType;

  AccountTypeModel({this.id, this.accountType});

  factory AccountTypeModel.fromDatabaseJson(Map<String, dynamic> data) {
    return AccountTypeModel(
      id: data[colId],
      accountType: data[colAccountType],
    );
  }

  Map<String, dynamic> toDatabaseJson() => {
        colId: this.id,
        colAccountType: this.accountType,
      };

  // Equatable
  @override
  List<Object> get props => [id];
}
