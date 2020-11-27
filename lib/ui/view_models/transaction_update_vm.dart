import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:logging/logging.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/category_model.dart';
import 'package:money_manager/core/models/database/transaction_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';
import 'package:money_manager/core/models/form/validation_item.dart';
import 'package:money_manager/core/providers/database/providers.dart';

class TransactionUpdateVm extends ChangeNotifier {
  final log = Logger('TransactionUpdateVm');

  static final provider = ChangeNotifierProvider.autoDispose
      .family<TransactionUpdateVm, AccountMasterModel>(
    (ref, initialAccount) {
      final txnTypes = ref
          .watch(DbProviders.transactionTypeProvider)
          .formTransactionTypeList;
      final accounts =
          ref.watch(DbProviders.accountsMasterProvider).accountsList;
      final categories = ref.watch(DbProviders.categoryProvider).categoryList;

      return TransactionUpdateVm(
        transactionTypes: txnTypes,
        accounts: accounts,
        categories: categories,
        refRead: ref.read,
        initialAccount: initialAccount,
      );
    },
  );

  Reader read;

  // Other Provider Values
  List<TransactionTypeModel> _txnTypes;
  List<AccountMasterModel> _accounts;
  List<CategoryModel> _categories;

  // Bottom NavBar index
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Getters for Other Provider Values
  TransactionTypeModel get selectedTxnType =>
      _txnTypes.length > 0 ? _txnTypes[_selectedIndex] : null;
  // // Account(s)
  List<AccountMasterModel> get accounts => _accounts;
  AccountMasterModel selectedfromAccount;
  AccountMasterModel selectedToAccount;
  // // Category
  List<CategoryModel> _selectedCategory = [null, null, null];
  get selectedCategory => _selectedCategory[
      _selectedIndex]; // No return type to allow setter to use int
  set selectedCategory(int id) {
    // int used to allow usage to be cleaner
    _selectedCategory[_selectedIndex] = _categories?.firstWhere(
      (element) => element.id == id,
      orElse: () => null, // Function that returns null, when not found
    );
    notifyListeners();
  }

  // Transaction Time
  DateTime modifiedTime = DateTime.now();
  DateTime _transactionTime = DateTime.now();
  get transactionTime => _transactionTime;
  set transactionTime(DateTime value) {
    _transactionTime = value;
    notifyListeners();
  }

  // Fields
  // // Amount
  ValidationItem amount =
      ValidationItem(value: '', isValid: false, error: 'Amount is required');
  void setAmount(String value) {
    value ??= '';
    bool isNumeric = double.tryParse(value) != null;

    if (value.isEmpty) {
      amount = ValidationItem(
          value: '', isValid: false, error: 'Amount is required');
    } else if (!isNumeric) {
      amount = ValidationItem(
          value: '', isValid: false, error: 'Amount should be a valid number');
    } else if (double.parse(value) < 0) {
      amount = ValidationItem(
          value: '', isValid: false, error: 'Amount should be positive');
    } else {
      amount = ValidationItem(value: value, isValid: true, error: null);
    }

    notifyListeners();
  }

  // // Description
  ValidationItem description = ValidationItem(isValid: true);
  void setDescription(String value) {
    description = ValidationItem(value: value, isValid: true);
    notifyListeners();
  }

  // Constructor
  TransactionUpdateVm({
    List<TransactionTypeModel> transactionTypes,
    List<AccountMasterModel> accounts,
    List<CategoryModel> categories,
    Reader refRead,
    AccountMasterModel initialAccount,
  }) {
    _txnTypes = transactionTypes;
    _accounts = accounts;
    _categories = categories;
    read = refRead;

    if (accounts.length > 0) {
      selectedfromAccount = initialAccount ?? accounts[0];
      selectedToAccount = accounts[0];
    }
  }

  Future<bool> save() async {
    if (amount.isValid && description.isValid) {
      // First transaction (Income, Expense, Transfer-Debit)
      TransactionModel txn = TransactionModel(
        fkAccountId: selectedfromAccount.id,
        fkTransactionTypeId: selectedTxnType.id,
        fkCategoryId: selectedCategory?.id ?? 0,
        transactionTime: _transactionTime.millisecondsSinceEpoch,
        modifiedTime: modifiedTime.millisecondsSinceEpoch,
        debitAmount: [1, 2].contains(selectedIndex)
            ? double.tryParse(amount.value)
            : 0.0,
        creditAmount: selectedIndex == 0 ? double.tryParse(amount.value) : 0.0,
        description: description.value,
      );

      // For transfers
      if (selectedIndex == 2) {
        if (selectedfromAccount != selectedToAccount) {
          return Future.delayed(Duration(seconds: 0), () => false);
        }

        // Second transaction (Transfer-Credit)
        TransactionModel txn2 = TransactionModel(
          fkAccountId: selectedToAccount.id,
          fkTransactionTypeId: selectedTxnType.id,
          fkCategoryId: selectedCategory?.id ?? 0,
          transactionTime: _transactionTime.millisecondsSinceEpoch,
          modifiedTime: modifiedTime.millisecondsSinceEpoch,
          debitAmount: 0.0,
          creditAmount: double.tryParse(amount.value),
          description: description.value,
        );

        int insertedId =
            await read(DbProviders.transactionProvider).addTransaction(txn);
        int insertedId2 =
            await read(DbProviders.transactionProvider).addTransaction(txn2);
        return insertedId > 0 && insertedId2 > 0;
      } else {
        int insertedId =
            await read(DbProviders.transactionProvider).addTransaction(txn);
        return insertedId > 0;
      }
    } else {
      return Future.delayed(Duration(seconds: 0), () => false);
    }
  }

  cancel() {}
}
