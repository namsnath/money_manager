import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/ui/views/home_page.dart';
import 'package:money_manager/ui/views/transaction_update_page.dart';

void main() {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name} (${record.loggerName}): ${record.time}: ${record.message}');
  });

  runApp(
    ProviderScope(
      child: App(),
    ),
  );

  DatabaseProvider.dbProvider.init();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData.dark(),
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('HomePage'),
            child: HomePage(),
          ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      ),
    );
  }
}
