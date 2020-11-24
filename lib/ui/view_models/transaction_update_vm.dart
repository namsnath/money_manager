import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';

class TransactionUpdateVm extends ChangeNotifier {
  final log = Logger('TransactionUpdateVm');

  List<TransactionTypeModel> _txnTypes;
  int _selectedIndex = 0;

  List<BottomNavigationBarItem> txnTypeItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up),
      label: 'Income',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_down),
      label: 'Expense',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz),
      label: 'Transfer',
    ),
  ];

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  TransactionTypeModel get selectedItem =>
      _txnTypes.length > 0 ? _txnTypes[_selectedIndex] : null;

  TransactionUpdateVm(List<TransactionTypeModel> txnTypes) {
    _txnTypes = txnTypes;
  }
}
