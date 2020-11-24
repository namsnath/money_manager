import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/providers/transaction_provider.dart';
import 'package:money_manager/core/providers/transaction_type_provider.dart';
import 'package:money_manager/ui/view_models/transaction_update_vm.dart';

class TransactionUpdatePage extends HookWidget {
  final Logger log = Logger('TransactionUpdate');
  final vmProvider = ChangeNotifierProvider<TransactionUpdateVm>(
    (ref) {
      final txnTypes =
          ref.watch(transactionTypeProvider).formTransactionTypeList;
      return TransactionUpdateVm(txnTypes);
    },
  );

  final List<BottomNavigationBarItem> bottomNavTxnTypeItems = [
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

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(vmProvider);
    final txnProvider = useProvider(transactionProvider);

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavTxnTypeItems,
        currentIndex: provider.selectedIndex,
        onTap: (int index) => context.read(vmProvider).selectedIndex = index,
      ),
      body: Center(
        child: Form(
          child: Column(
            children: <Widget>[
              Text('Selected: ${provider.selectedIndex}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Spacer(flex: 1),
                  Expanded(
                    flex: 2,
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Spacer(flex: 1),
                  Expanded(
                    flex: 3,
                    child: RaisedButton(
                      color: Colors.green,
                      child: Text('Save'),
                      onPressed: () async {
                        log.info('Clicked Save');
                        final agg = await txnProvider.getAggregates();
                        log.info(agg);
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
              // CircleBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}
