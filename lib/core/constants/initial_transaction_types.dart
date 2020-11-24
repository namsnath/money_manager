class InitialTransactionTypes {
  static const List<List<dynamic>> _data = [
    [1, 'Income'],
    [2, 'Expense'],
    [3, 'Transfer'],
    [4, 'Investment'],
    [5, 'Investment Return'],
  ];

  static String get data => _data.map((row) {
        String rowData = row
            .map((col) => (col == null || col == '') ? 'NULL' : '"$col"')
            .join(',');

        return '($rowData)';
      }).join(',');
}
