import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/providers/database/providers.dart';
import 'package:money_manager/ui/view_models/transaction_update_vm.dart';

// ScopedProvider to allow using the same value for all provider initialisations
final initialAccountScopeProvider = ScopedProvider<AccountMasterModel>(null);

class TransactionUpdatePage extends HookWidget {
  TransactionUpdatePage({
    this.initialAccount,
  });

  final AccountMasterModel initialAccount;

  final Logger log = Logger('TransactionUpdate');

  final List<Tab> txnTypeTabs = [
    Tab(
      icon: Icon(Icons.trending_up),
      text: 'Income',
    ),
    Tab(
      icon: Icon(Icons.trending_down),
      text: 'Expense',
    ),
    Tab(
      icon: Icon(Icons.swap_horiz),
      text: 'Transfer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: txnTypeTabs.length);
    tabController.addListener(() {
      context.read(TransactionUpdateVm.provider(initialAccount)).selectedIndex =
          tabController.index;
    });

    return ProviderScope(
      overrides: [
        // Override the scope with the passed account, so every widget uses the same provider
        initialAccountScopeProvider.overrideWithValue(initialAccount),
      ],
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: tabController,
            tabs: txnTypeTabs,
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: txnTypeTabs
              .asMap() // Workaround to access index
              .map(
                (i, _) => MapEntry(
                  i,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: FieldsCard(selectedIndex: i),
                  ),
                ),
              )
              .values // Convert from MapEntry to List
              .toList(),
        ),
      ),
    );
  }
}

class FieldsCard extends HookWidget {
  FieldsCard({
    this.selectedIndex,
  });

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    Column fieldsColumn;

    if (selectedIndex == 0) {
      fieldsColumn = Column(
        children: [
          TimeButtons(),
          AccountDropdowns(),
          AmountField(),
          CategoryButton(),
          DescriptionField(),
          SizedBox(height: 20),
          ActionButtons(),
        ],
      );
    } else if (selectedIndex == 1) {
      fieldsColumn = Column(
        children: [
          TimeButtons(),
          AccountDropdowns(),
          AmountField(),
          CategoryButton(),
          DescriptionField(),
          SizedBox(height: 20),
          ActionButtons(),
        ],
      );
    } else if (selectedIndex == 2) {
      fieldsColumn = Column(
        children: [
          TimeButtons(),
          AccountDropdowns(transfer: true),
          AmountField(),
          DescriptionField(),
          SizedBox(height: 20),
          ActionButtons(),
        ],
      );
    }

    return ListView(
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            child: fieldsColumn,
          ),
        ),
      ],
    );
  }
}

class TimeButtons extends HookWidget {
  final DateFormat dateFormatter = new DateFormat.yMMMd();
  final DateFormat timeFormatter = new DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);
    final provider = useProvider(TransactionUpdateVm.provider(initialAccount));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Builder(
          builder: (context) => RaisedButton.icon(
            onPressed: () async {
              final providerDate = provider.transactionTime;

              final DateTime picked = await showDatePicker(
                context: context,
                initialDate: provider.transactionTime,
                firstDate: DateTime(1980),
                lastDate: DateTime(9999),
              );

              if (picked != null && picked != providerDate) {
                provider.transactionTime = DateTime(picked.year, picked.month,
                    picked.day, providerDate.hour, providerDate.minute);
              }
            },
            icon: Icon(Icons.calendar_today),
            label: Text(
              dateFormatter.format(provider.transactionTime),
            ),
          ),
        ),
        Builder(
          builder: (context) => RaisedButton.icon(
            onPressed: () async {
              final providerDate = provider.transactionTime;

              final TimeOfDay picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: providerDate.hour,
                  minute: providerDate.minute,
                ),
              );

              if (picked != null &&
                  (picked.hour != providerDate.hour ||
                      picked.minute != providerDate.minute)) {
                provider.transactionTime = DateTime(
                  providerDate.year,
                  providerDate.month,
                  providerDate.day,
                  picked.hour,
                  picked.minute,
                );
              }
            },
            icon: Icon(Icons.access_time),
            label: Text(
              timeFormatter.format(provider.transactionTime),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryDialog extends HookWidget {
  CategoryDialog({this.categoryTree});

  final List<Node<dynamic>> categoryTree;

  @override
  Widget build(BuildContext context) {
    TreeViewController _treeViewController = TreeViewController(
      children: categoryTree,
      selectedKey: null,
    );

    TreeViewTheme __treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
        type: ExpanderType.plusMinus,
        size: 18,
        color: Theme.of(context).textTheme.bodyText1.color,
      ),
      colorScheme: Theme.of(context).brightness == Brightness.light
          ? ColorScheme.light(
              background: Colors.transparent,
              onBackground: Theme.of(context).textTheme.bodyText1.color,
            )
          : ColorScheme.dark(
              background: Colors.transparent,
              onBackground: Theme.of(context).textTheme.bodyText1.color,
            ),
    );

    return AlertDialog(
      title: Text(
        'Double tap to select category',
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: 400,
        width: 300,
        child: TreeView(
          controller: _treeViewController,
          theme: __treeViewTheme,
          supportParentDoubleTap: true,
          onNodeDoubleTap: (key) {
            int returnVal = int.tryParse(key) ?? 0;
            Navigator.of(context, rootNavigator: true).pop(returnVal);
          },
        ),
      ),
    );
  }
}

class CategoryButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);
    final provider = useProvider(TransactionUpdateVm.provider(initialAccount));
    final catProvider = useProvider(DbProviders.categoryProvider);

    final categoryBtnText =
        catProvider.categoryHierarchyMap[provider.selectedCategory?.id ?? 0] ??
            'Uncategorized';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Expanded(
          flex: 1,
          child: Icon(Icons.category),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 12,
          child: RaisedButton(
            child: Text(categoryBtnText),
            onPressed: () async {
              int selectedId = await showDialog<int>(
                    context: context,
                    builder: (_) => CategoryDialog(
                      categoryTree: catProvider.getCategoryTree(
                        transactionTypeId: provider.selectedTxnType.id,
                      ),
                    ),
                  ) ??
                  0; // Default value if dialog closed without selection

              // This allows to persist provider state instead of setting to 0
              if (selectedId != 0) {
                provider.selectedCategory = selectedId;
              }
            },
          ),
        ),
      ],
    );
  }
}

class AmountField extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);
    final provider = useProvider(TransactionUpdateVm.provider(initialAccount));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Expanded(
          flex: 1,
          child: Icon(Icons.attach_money),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 12,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Amount',
              errorText: provider.amount.error,
            ),
            initialValue: provider.amount.value,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              provider.setAmount(value);
            },
          ),
        ),
      ],
    );
  }
}

class DescriptionField extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);
    final provider = useProvider(TransactionUpdateVm.provider(initialAccount));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Expanded(
          flex: 1,
          child: Icon(Icons.short_text),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 12,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              errorText: provider.description.error,
            ),
            initialValue: provider.description.value,
            textInputAction: TextInputAction.next,
            onChanged: (String value) {
              provider.setDescription(value);
            },
          ),
        ),
      ],
    );
  }
}

class AccountDropdowns extends HookWidget {
  AccountDropdowns({
    this.transfer = false,
  });

  final bool transfer;

  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);
    final provider = useProvider(TransactionUpdateVm.provider(initialAccount));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Expanded(
          flex: 1,
          child: Icon(Icons.account_balance_wallet),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 5,
          child: DropdownButton<AccountMasterModel>(
            hint: Text('From Account'),
            value: provider.selectedfromAccount,
            items: provider?.accounts
                    ?.map(
                      (v) => DropdownMenuItem(
                        child: Text('${v.account} (${v.institution})'),
                        value: v,
                      ),
                    )
                    ?.toList() ??
                [],
            onChanged: (AccountMasterModel newValue) {
              provider.selectedfromAccount = newValue;
            },
            underline: Text(''),
          ),
        ),
        transfer
            ? Expanded(
                flex: 2,
                child: Text(
                  'To',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Spacer(flex: 2),
        transfer
            ? Expanded(
                flex: 5,
                child: DropdownButton<AccountMasterModel>(
                  hint: Text('To Account'),
                  value: provider.selectedfromAccount,
                  items: provider?.accounts
                          ?.map(
                            (v) => DropdownMenuItem(
                              child: Text('${v.account} (${v.institution})'),
                              value: v,
                            ),
                          )
                          ?.toList() ??
                      [],
                  onChanged: (AccountMasterModel newValue) {
                    provider.selectedfromAccount = newValue;
                  },
                  underline: Text(''),
                ),
              )
            : Spacer(flex: 5),
      ],
    );
  }
}

class ActionButtons extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialAccount = useProvider(initialAccountScopeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Spacer(flex: 1),
        Expanded(
          flex: 2,
          child: RaisedButton(
            color: Colors.red,
            child: Text('Cancel'),
            onPressed: () async {
              context
                  .read(TransactionUpdateVm.provider(initialAccount))
                  .cancel();
              Navigator.of(context).pop();
            },
          ),
        ),
        Spacer(flex: 1),
        Expanded(
          flex: 3,
          child: RaisedButton(
            color: Colors.green,
            child: Text('Save'),
            onPressed: () async {
              if (await context
                  .read(TransactionUpdateVm.provider(initialAccount))
                  .save()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        Spacer(flex: 1),
      ],
    );
  }
}
