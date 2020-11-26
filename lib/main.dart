import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:money_manager/core/database/database.dart';
import 'package:money_manager/core/providers/theme_provider.dart';
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

  DatabaseHelper.dbProvider.init();
}

class App extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final provider = useProvider(themeProvider);

    return MaterialApp(
      title: 'Money Manager',
      theme: provider.currentTheme,
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
