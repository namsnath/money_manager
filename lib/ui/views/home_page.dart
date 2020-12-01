import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';

import 'package:money_manager/core/providers/database/providers.dart';
import 'package:money_manager/core/providers/theme_provider.dart';
import 'package:money_manager/core/utils/datetime_util.dart';
import 'package:money_manager/ui/views/transaction_update_page.dart';
import 'package:money_manager/ui/widgets/category_chart.dart';

class HomePage extends HookWidget {
  const HomePage({Key key}) : super(key: key);
  static final log = Logger('HomePage');

  @override
  Widget build(BuildContext context) {
    final accProvider = useProvider(DbProviders.accountsMasterProvider);

    final _accountTabs = accProvider.accountsList
        .map((v) => Tab(text: '${v.account} (${v.institution})'))
        .toList();

    final _tabViews = accProvider.accountsList
        .map(
          (v) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                children: [
                  AccountSummary(account: v),
                  CategoryChartCard(account: v),
                ],
              ),
            ),
          ),
        )
        .toList();

    return DefaultTabController(
      length: accProvider.accountsList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Money Manager'),
          actions: [
            IconButton(
              tooltip: 'Toggle Theme',
              icon: Icon(Icons.invert_colors),
              onPressed: () => context.read(themeProvider).toggleTheme(),
            ),
          ],
          bottom: TabBar(tabs: _accountTabs),
        ),
        body: TabBarView(children: _tabViews),
        floatingActionButton: Builder(
          builder: (tabContext) => FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => TransactionUpdatePage(
                  initialAccount: accProvider
                      .accountsList[DefaultTabController.of(tabContext).index],
                ),
              ),
            ),
            tooltip: 'Add Transaction',
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

// Builds the Generic summary layout for the given account
class AccountSummary extends HookWidget {
  AccountSummary({
    this.account,
  });

  final AccountMasterModel account;

  @override
  Widget build(BuildContext context) {
    final txnProvider = useProvider(DbProviders.transactionProvider);
    final accProvider = useProvider(DbProviders.accountsMasterProvider);
    final selectedAccount = accProvider.accountsList
        ?.elementAt(DefaultTabController.of(context).index);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: txnProvider.getAggregates(account: selectedAccount),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SummaryDetails(data: snapshot.data);
              } else if (snapshot.hasError) {
                return Text('Error');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}

// Builds the card layout for the account summary
class SummaryDetails extends StatelessWidget {
  SummaryDetails({
    this.data,
  });

  final Map<String, Map<String, double>> data;

  final todayFormat = DateFormat.yMMMEd();
  final weekFormat = DateFormat.MMMEd();
  final monthFormat = DateFormat.MMMEd();
  final yearFormat = DateFormat.MMMEd();

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();

    final today = todayFormat.format(currentDate);

    final weekStart = weekFormat.format(DateTimeUtil.startOfWeek(date: currentDate));
    final weekEnd = weekFormat.format(DateTimeUtil.endOfWeek(date: currentDate));

    final monthStart =
        monthFormat.format(DateTimeUtil.startOfMonth(date: currentDate));
    final monthEnd = monthFormat.format(DateTimeUtil.endOfMonth(date: currentDate));

    final yearStart = yearFormat.format(DateTimeUtil.startOfYear(date: currentDate));
    final yearEnd = yearFormat.format(DateTimeUtil.endOfYear(date: currentDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(today),
          ],
        ),
        Row(
          children: [
            SummaryCard(
              type: Activity.income,
              value: data['credit']['day'],
              // onTap: () => log.info('$title Income tapped'),
            ),
            SummaryCard(
              type: Activity.expense,
              value: data['debit']['day'],
              // onTap: () => log.info('$title Expense tapped'),
            ),
            SummaryCard(
              type: Activity.balance,
              value: data['balance']['day'],
              // onTap: () => log.info('$title Balance tapped'),
            ),
          ],
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text('$weekStart - $weekEnd'),
          ],
        ),
        Row(
          children: [
            SummaryCard(
              type: Activity.income,
              value: data['credit']['week'],
              // onTap: () => log.info('$title Income tapped'),
            ),
            SummaryCard(
              type: Activity.expense,
              value: data['debit']['week'],
              // onTap: () => log.info('$title Expense tapped'),
            ),
            SummaryCard(
              type: Activity.balance,
              value: data['balance']['week'],
              // onTap: () => log.info('$title Balance tapped'),
            ),
          ],
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Month',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text('$monthStart - $monthEnd'),
          ],
        ),
        Row(
          children: [
            SummaryCard(
              type: Activity.income,
              value: data['credit']['month'],
              // onTap: () => log.info('$title Income tapped'),
            ),
            SummaryCard(
              type: Activity.expense,
              value: data['debit']['month'],
              // onTap: () => log.info('$title Expense tapped'),
            ),
            SummaryCard(
              type: Activity.balance,
              value: data['balance']['month'],
              // onTap: () => log.info('$title Balance tapped'),
            ),
          ],
        ),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Year',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text('$yearStart - $yearEnd'),
          ],
        ),
        Row(
          children: [
            SummaryCard(
              type: Activity.income,
              value: data['credit']['year'],
              // onTap: () => log.info('$title Income tapped'),
            ),
            SummaryCard(
              type: Activity.expense,
              value: data['debit']['year'],
              // onTap: () => log.info('$title Expense tapped'),
            ),
            SummaryCard(
              type: Activity.balance,
              value: data['balance']['year'],
              // onTap: () => log.info('$title Balance tapped'),
            ),
          ],
        ),
        SizedBox(height: 15.0),
      ],
    );
  }
}

// Enum for Activity types
enum Activity {
  income,
  expense,
  balance,
}

// Widget to render the Summary Cards
class SummaryCard extends StatelessWidget {
  SummaryCard({
    this.type = Activity.income,
    this.value = 0.0,
    this.onTap,
  });

  final Activity type;
  final double value;
  final Function onTap;

  String get title {
    switch (type) {
      case Activity.balance:
        return 'Balance';
      case Activity.income:
        return 'Income';
      case Activity.expense:
        return 'Expense';
      default:
        return '';
    }
  }

  Color get valueColor {
    switch (type) {
      case Activity.balance:
        return value > 0 ? Colors.green : Colors.red;
      case Activity.income:
        return Colors.green;
      case Activity.expense:
        return Colors.red;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 3.0),
            child: Column(
              children: [
                Text(title),
                SizedBox(height: 5.0),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
