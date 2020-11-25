import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:money_manager/core/providers/accounts_master_provider.dart';
import 'package:money_manager/core/providers/theme_provider.dart';
import 'package:money_manager/core/providers/transaction_provider.dart';
import 'package:money_manager/ui/views/transaction_update_page.dart';

class HomePage extends HookWidget {
  const HomePage({Key key}) : super(key: key);
  static final log = Logger('HomePage');

  List<Text> getAccounts(BuildContext context) {
    final accounts = useProvider(accountsMasterProvider);

    final accountsText = accounts.accountsList
        .map((v) => Text(
              '${v.account} (${v.institution})',
              style: Theme.of(context).textTheme.headline4,
            ))
        .toList();

    return accountsText;
  }

  Widget getAggregateWidget() {
    final txnProvider = useProvider(transactionProvider);
    final aggregates = txnProvider.getAggregates();

    return FutureBuilder(
      future: aggregates,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              activityCards(
                context,
                title: 'Today',
                income: snapshot.data['credit']['day'],
                expense: snapshot.data['debit']['day'],
                balance: snapshot.data['balance']['day'],
              ),
              activityCards(
                context,
                title: 'This Week',
                income: snapshot.data['credit']['week'],
                expense: snapshot.data['debit']['week'],
                balance: snapshot.data['balance']['week'],
              ),
              activityCards(
                context,
                title: 'This Month',
                income: snapshot.data['credit']['month'],
                expense: snapshot.data['debit']['month'],
                balance: snapshot.data['balance']['month'],
              ),
              activityCards(
                context,
                title: 'This Year',
                income: snapshot.data['credit']['year'],
                expense: snapshot.data['debit']['year'],
                balance: snapshot.data['balance']['year'],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error');
        } else {
          return Text('Loading');
        }
      },
    );
  }

  Column activityCards(BuildContext context,
      {String title, double income = 0, double expense = 0, balance = 0}) {
    // double balance = income - expense;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                    child: Column(
                      children: [
                        Text('Income'),
                        SizedBox(height: 5.0),
                        Text(
                          income.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => log.info('$title Income tapped'),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                    child: Column(
                      children: [
                        Text('Expense'),
                        SizedBox(height: 5.0),
                        Text(
                          expense.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => log.info('$title Expense tapped'),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                    child: Column(
                      children: [
                        Text('Balance'),
                        SizedBox(height: 5.0),
                        Text(
                          balance.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (balance > 0) ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => log.info('$title Balance tapped'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Manager Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.invert_colors),
            onPressed: () => context.read(themeProvider).toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getAggregateWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TransactionUpdatePage(),
          ),
        ),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
