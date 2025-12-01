class DateUtilsCustom {
  static String formatShort(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
}
