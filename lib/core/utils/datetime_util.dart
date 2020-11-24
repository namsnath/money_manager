class DateTimeUtil {
  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  static DateTime firstDayOfWeek(DateTime day) {
    // Handle Daylight Savings by setting hour to 12:00 Noon
    // rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    // Weekday is on a 1-7 scale Monday - Sunday,
    // This Calendar works from Sunday - Monday
    var decreaseNum = day.weekday % 7;
    return day.subtract(Duration(days: decreaseNum));
  }

  static DateTime lastDayOfWeek(DateTime day) {
    // Handle Daylight Savings by setting hour to 12:00 Noon
    // rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    // Weekday is on a 1-7 scale Monday - Sunday,
    // This Calendar's Week starts on Sunday
    var increaseNum = day.weekday % 7;
    return day.add(Duration(days: 7 - increaseNum));
  }

  // The last day of a given month
  static DateTime lastDayOfMonth(DateTime month) {
    var beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(Duration(days: 1));
  }

  // Custom methods

  // Start of ... methods

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime startOfWeek(DateTime date) {
    DateTime startDate = firstDayOfWeek(date);
    return DateTime(startDate.year, startDate.month, startDate.day);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year);
  }

  // End of ... methods

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime endOfWeek(DateTime date) {
    DateTime endDate = firstDayOfWeek(date);
    return DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    }

  static DateTime endOfMonth(DateTime date) {
    var beginningNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1)
        : DateTime(date.year + 1, 1);
    beginningNextMonth = beginningNextMonth.subtract(Duration(milliseconds: 1));

    return DateTime(beginningNextMonth.year, beginningNextMonth.month);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year + 1).subtract(Duration(milliseconds: 1));
  }
}
