import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/providers/database/providers.dart';
import 'package:money_manager/core/providers/transaction_type_toggle_provider.dart';

class TransactionTypeToggle extends HookWidget {
  final txnTypeToggleProvider =
      ChangeNotifierProvider<TransactionTypeToggleProvider>((ref) {
    final txnTypes = ref.watch(DbProviders.transactionTypeProvider).formTransactionTypeList;

    return TransactionTypeToggleProvider(txnTypes);
  });

  TransactionTypeToggle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(txnTypeToggleProvider);

    final transactionTypes = provider?.transactionTypes;
    final transactionTypeIsSelected = transactionTypes
        .map((v) => provider.selectedTransactionType == v)
        .toList();

    List<Widget> buttons = transactionTypes
        .map((v) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                v.transactionType,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ToggleButtons(
        children: buttons,
        isSelected: transactionTypeIsSelected,
        onPressed: (int index) {
          provider.changeSelectedTxnType(transactionTypes[index]);
        },
        borderRadius: BorderRadius.circular(10),
        constraints: BoxConstraints.tightFor(height: 35.0),
      ),
    );
  }
}
