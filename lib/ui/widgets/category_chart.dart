import 'package:charts_flutter/flutter.dart' as charts;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'dart:math' as math;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:money_manager/core/database/queries.dart';
import 'package:money_manager/core/models/database/account_master_model.dart';
import 'package:money_manager/core/models/database/transaction_type_model.dart';
import 'package:money_manager/core/providers/database/providers.dart';
import 'package:money_manager/core/utils/datetime_util.dart';

class CategoryAggregateData with EquatableMixin {
  final AccountMasterModel account;
  final TransactionTypeModel txnType;
  final int parentId;

  CategoryAggregateData({this.account, this.txnType, this.parentId});

  @override
  List<Object> get props => [account, txnType];
}

// TODO: Add TxnType Picker
class CategoryChartCard extends HookWidget {
  final AccountMasterModel account;

  CategoryChartCard({
    this.account,
  });

  @override
  Widget build(BuildContext context) {
    final selectedId = useState(0);
    final parentIds = useState(<int>[0]);
    final parentNames = useState(<String>['All']);

    _changeId(int currentId, String parentName) {
      selectedId.value = currentId;
      parentIds.value.add(currentId);
      parentNames.value.add(parentName);
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                Text('Category: '),
                BreadCrumb.builder(
                  itemCount: parentIds.value.length,
                  builder: (index) => BreadCrumbItem(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5.0,
                      ),
                      content: Text(
                        parentNames.value[index],
                        style: TextStyle(
                          fontWeight: index == parentIds.value.length - 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        if (parentIds.value.length - 1 == index) return;

                        selectedId.value = parentIds.value[index];
                        parentIds.value = parentIds.value.sublist(0, index + 1);
                        parentNames.value =
                            parentNames.value.sublist(0, index + 1);
                      }),
                  divider: Icon(Icons.chevron_right),
                  overflow: ScrollableOverflow(),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              width: double.infinity,
              child: CategoryChart(
                account: account,
                parentId: selectedId.value,
                changeId: _changeId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: Fix chart overflowing Card (Reduced chart size for now)
class CategoryChart extends HookWidget {
  final AccountMasterModel account;
  final int parentId;
  final Function changeId;

  CategoryChart({
    this.account,
    this.parentId,
    this.changeId,
  });

  final futureQuery = FutureProvider.autoDispose
      .family<List<Map<String, dynamic>>, CategoryAggregateData>(
          (ref, data) async {
    final catProvider = ref.watch(DbProviders.categoryProvider);

    return await Queries.getCategoryAggregate(
      startTime:
          DateTimeUtil.startOfMonth(DateTime.now()).millisecondsSinceEpoch,
      endTime: DateTimeUtil.endOfMonth(DateTime.now()).millisecondsSinceEpoch,
      categoryHierarchy: catProvider?.categoryHierarchy ?? [],
      account: data.account,
      parentId: data.parentId,
    );
  });

  @override
  Widget build(BuildContext context) {
    // final selectedCatId = useState(57);
    final futureProvider = useProvider(
      futureQuery(
        CategoryAggregateData(
          account: account,
          parentId: parentId,
        ),
      ),
    );

    Widget child = SizedBox(
      height: 50,
      width: 50,
      child: CircularProgressIndicator(),
    );

    if (futureProvider.data != null) {
      child = charts.PieChart(
        [
          charts.Series(
            id: 'chart',
            data: futureProvider.data.value,
            domainFn: (value, _) => value['category'],
            measureFn: (value, _) => value['debitAggregate'],
            // colorFn: (value, _) => charts.ColorUtil.fromDartColor(
            //     Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            //         .withOpacity(1.0)),
            labelAccessorFn: (value, _) =>
                '${value['category']}\n(${value['debitAggregate']})',
          ),
        ],
        animate: true,
        behaviors: [
          // charts.DatumLegend(),
        ],
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 40,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              outsideLabelStyleSpec: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).textTheme.bodyText1.color),
                fontSize: 12,
              ),
              leaderLineStyleSpec: charts.ArcLabelLeaderLineStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                    Theme.of(context).textTheme.bodyText1.color),
                thickness: 1.0,
                length: 20.0,
              ),
              labelPosition: charts.ArcLabelPosition.outside,
            ),
          ],
        ),
        selectionModels: [
          charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: (model) {
              final selectedDatum = model.selectedDatum[0].datum;
              final childrenCount = selectedDatum['childrenCount'];
              if (childrenCount == 0) return;

              changeId(
                int.parse(selectedDatum['currentId']),
                selectedDatum['category'],
              );
            },
          ),
        ],
      );
    }

    return child;
  }
}
