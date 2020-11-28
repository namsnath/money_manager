import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

TabController useTabController({
  @required int length,
  int initialIndex = 0,
}) {
  final tickerProvider = useSingleTickerProvider(
    keys: [length, initialIndex],
  );

  final controller = useMemoized(
    () => TabController(
        length: length, vsync: tickerProvider, initialIndex: initialIndex),
    [tickerProvider],
  );

  useEffect(
    () {
      return controller.dispose;
    },
    [controller],
  );

  return controller;
}
