import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/providers/database/accounts_master_provider.dart';
import 'package:money_manager/core/providers/database/category_provider.dart';
import 'package:money_manager/core/providers/database/transaction_provider.dart';
import 'package:money_manager/core/providers/database/transaction_type_provider.dart';

class DbProviders {
  static final accountsMasterProvider =
      ChangeNotifierProvider((_) => AccountsMasterProvider());

  static final categoryProvider = ChangeNotifierProvider((_) => CategoryProvider());

  static final transactionProvider =
      ChangeNotifierProvider((_) => TransactionProvider());

  static final transactionTypeProvider =
      ChangeNotifierProvider((_) => TransactionTypeProvider());
}
