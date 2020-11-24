class InitialCategories {
  // [PK, ParentID, TxnTypeID, Category]
  static const _data = [
    // Income
    [1, 0, 1, 'Initial Balance'],
    [2, 0, 1, 'Salary'],
    [3, 0, 1, 'Allowance'],
    [4, 0, 1, 'Freelance'],
    
    // Expense
    // Food/Drink
    [5, 0, 2, 'Food/Drink'],
    [6, 5, 2, 'Restaurant'],
    [7, 5, 2, 'Snack'],
    [8, 5, 2, 'Other'],
    // Entertainment
    [9, 0, 2, 'Entertainment'],
    [10, 9, 2, 'Concert'],
    [11, 9, 2, 'Movie'],
    [12, 9, 2, 'Party'],
    [13, 9, 2, 'Other'],
    // Personal
    [14, 0, 2, 'Personal'],
    [15, 14, 2, 'Clothing'],
    [16, 14, 2, 'Gift'],
    [17, 14, 2, 'Clothing'],
    [18, 14, 2, 'Care'],
    [19, 14, 2, 'Other'],
    // Groceries
    [20, 0, 2, 'Groceries'],
    [21, 20, 2, 'Food'],
    [22, 20, 2, 'Drink'],
    [23, 20, 2, 'Essentials'],
    [24, 20, 2, 'Other'],
    // Travel
    [25, 0, 2, 'Travel'],
    [26, 25, 2, 'Airplane'],
    [27, 25, 2, 'Car Rental'],
    [28, 25, 2, 'Train'],
    [29, 25, 2, 'Taxi'],
    [30, 25, 2, 'Hotel'],
    [31, 25, 2, 'Food/Drink'],
    [32, 25, 2, 'Other'],
    // Local Travel
    [33, 0, 2, 'Local Travel'],
    [34, 33, 2, 'Taxi'],
    [35, 33, 2, 'Shuttle'],
    [36, 33, 2, 'Other'],
    // Utilities
    [37, 0, 2, 'Utilities'],
    [38, 37, 2, 'Internet'],
    [39, 37, 2, 'Telephone'],
    [40, 37, 2, 'Electric'],
    [41, 37, 2, 'Laundry'],
    [42, 37, 2, 'Water'],
    [43, 37, 2, 'Other'],
    // Vacation
    [44, 0, 2, 'Vacation'],
    [45, 44, 2, 'Airplane'],
    [46, 44, 2, 'Car Rental'],
    [47, 44, 2, 'Train'],
    [48, 44, 2, 'Taxi'],
    [49, 44, 2, 'Hotel'],
    [50, 44, 2, 'Food/Drink'],
    [51, 44, 2, 'Other'],
    // Home Office
    [52, 0, 2, 'Home Office'],
    [53, 52, 2, 'Stationery'],
    [54, 52, 2, 'Furniture'],
    [55, 52, 2, 'Electronics'],
    [56, 52, 2, 'Other'],
    // Healthcare
    [57, 0, 2, 'Healthcare'],
    [58, 57, 2, 'Medicine'],
    [59, 57, 2, 'Consultation'],
    [60, 57, 2, 'Physiotherapy'],
    [61, 57, 2, 'Other'],
    // Misc
    [62, 0, 2, 'Miscellaneous'],

    // Transfer
    [63, 0, 3, 'Account Transfer'],
    
    // Investment
    // [64, 0, 4, 'Investment'],

    // Investment Return
    // [65, 0, 5, 'Investment Return'],

    [64, 60, 2, 'Some Physio Sub-Category'],
  ];

  static String get data => _data.map((row) {
        String rowData = row
            .map((col) => (col == null || col == '') ? 'NULL' : '"$col"')
            .join(',');

        return '($rowData)';
      }).join(',');
}