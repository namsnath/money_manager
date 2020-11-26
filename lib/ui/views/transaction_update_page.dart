import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/providers/database/providers.dart';
import 'package:money_manager/ui/view_models/transaction_update_vm.dart';

class TransactionUpdatePage extends HookWidget {
  final Logger log = Logger('TransactionUpdate');

  final DateFormat dateFormatter = new DateFormat.yMMMd();
  final DateFormat timeFormatter = new DateFormat.jm();

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

  Row timeButtons() {
    final provider = useProvider(TransactionUpdateVm.provider);

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

  Row amountField() {
    final provider = useProvider(TransactionUpdateVm.provider);

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

  Row descriptionField() {
    final provider = useProvider(TransactionUpdateVm.provider);

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
            textInputAction: TextInputAction.next,
            onChanged: (String value) {
              provider.setDescription(value);
            },
          ),
        ),
      ],
    );
  }

  Row accountDropdowns({bool transfer = false}) {
    final provider = useProvider(TransactionUpdateVm.provider);

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

  Future<int> showCategoryDialog(
      BuildContext context, List<Node<dynamic>> categoryTree) {
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

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
    );
  }

  Row categoryButton() {
    final provider = useProvider(TransactionUpdateVm.provider);
    final catProvider = useProvider(DbProviders.categoryProvider);

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
          child: Builder(
            builder: (context) => RaisedButton(
              child: Text(catProvider.categoryHierarchyMap[
                      provider?.selectedCategory?.id ?? 0] ??
                  'Uncategorized'),
              onPressed: () async {
                int selectedId = await showCategoryDialog(
                      context,
                      catProvider.getCategoryTree(
                        transactionTypeId: provider.selectedTxnType.id,
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
        ),
      ],
    );
  }

  Column expenseFields() {
    return Column(
      children: [
        timeButtons(),
        accountDropdowns(),
        amountField(),
        categoryButton(),
        descriptionField(),
      ],
    );
  }

  Column incomeFields() {
    return Column(
      children: [
        timeButtons(),
        accountDropdowns(),
        amountField(),
        categoryButton(),
        descriptionField(),
      ],
    );
  }

  Column transferFields() {
    return Column(
      children: [
        timeButtons(),
        accountDropdowns(transfer: true),
        amountField(),
        descriptionField(),
      ],
    );
  }

  fieldsCard() {
    final provider = useProvider(TransactionUpdateVm.provider);
    Column fieldsColumn;

    if (provider.selectedIndex == 0) {
      fieldsColumn = expenseFields();
    } else if (provider.selectedIndex == 1) {
      fieldsColumn = incomeFields();
    } else if (provider.selectedIndex == 2) {
      fieldsColumn = transferFields();
    }

    return Expanded(
      child: ListView(
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
      ),
    );
  }

  Builder actionButtons() {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Spacer(flex: 1),
          Expanded(
            flex: 2,
            child: RaisedButton(
              color: Colors.red,
              child: Text('Cancel'),
              onPressed: () async {
                context.read(TransactionUpdateVm.provider).cancel();
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
                if (await context.read(TransactionUpdateVm.provider).save()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(TransactionUpdateVm.provider);

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavTxnTypeItems,
        currentIndex: provider.selectedIndex,
        onTap: (int index) => context.read(TransactionUpdateVm.provider).selectedIndex = index,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Form(
            child: Column(
              children: <Widget>[
                fieldsCard(),
                actionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
