import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class TransactionTypeToggleProvider extends ChangeNotifier {
  final log = Logger('TransactionTypeToggleProvider');

  TransactionTypeModel _selectedTransactionType;
  TransactionTypeModel get selectedTransactionType => _selectedTransactionType;

  List<TransactionTypeModel> _transactionTypes;
  List<TransactionTypeModel> get transactionTypes => _transactionTypes;

  TransactionTypeToggleProvider(List<TransactionTypeModel> txnTypes,
      {TransactionTypeModel selected}) {
    _transactionTypes = txnTypes;

    if (selected == null) {
      if (_transactionTypes.length > 0) {
        changeSelectedTxnType(_transactionTypes[0]);
      }
    } else {
      changeSelectedTxnType(selected);
    }
  }

  changeSelectedTxnType(TransactionTypeModel newType) {
    if (newType != null) {
      if (_transactionTypes?.contains(newType) ?? false) {
        _selectedTransactionType = newType;
        notifyListeners();
      }
    }
  }
}
