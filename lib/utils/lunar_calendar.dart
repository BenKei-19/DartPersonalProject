/// Simple Lunar Calendar utility to compute approximate Tết (Lunar New Year) dates.
/// Uses a lookup table for Tết dates from 2024 to 2040.
class LunarCalendar {
  // Tết Nguyên Đán dates (1st day of Lunar New Year)
  static final Map<int, DateTime> _tetDates = {
    2024: DateTime(2024, 2, 10),
    2025: DateTime(2025, 1, 29),
    2026: DateTime(2026, 2, 17),
    2027: DateTime(2027, 2, 6),
    2028: DateTime(2028, 1, 26),
    2029: DateTime(2029, 2, 13),
    2030: DateTime(2030, 2, 3),
    2031: DateTime(2031, 1, 23),
    2032: DateTime(2032, 2, 11),
    2033: DateTime(2033, 1, 31),
    2034: DateTime(2034, 2, 19),
    2035: DateTime(2035, 2, 8),
    2036: DateTime(2036, 1, 28),
    2037: DateTime(2037, 2, 15),
    2038: DateTime(2038, 2, 4),
    2039: DateTime(2039, 1, 24),
    2040: DateTime(2040, 2, 12),
  };

  /// Returns the next Tết Nguyên Đán date from now.
  static DateTime getNextTet() {
    final now = DateTime.now();
    for (final entry in _tetDates.entries) {
      if (entry.value.isAfter(now)) {
        return entry.value;
      }
    }
    // Fallback: approximate next Tết
    return DateTime(now.year + 1, 2, 1);
  }

  /// Returns the Tết date for a specific year (Gregorian year).
  static DateTime? getTetByYear(int year) {
    return _tetDates[year];
  }

  /// Returns the duration until the next Tết.
  static Duration getCountdown() {
    final nextTet = getNextTet();
    return nextTet.difference(DateTime.now());
  }

  /// Returns the Lunar year animal for a given year.
  static String getAnimal(int year) {
    const animals = [
      'Tý (Chuột)', 'Sửu (Trâu)', 'Dần (Hổ)', 'Mão (Mèo)',
      'Thìn (Rồng)', 'Tỵ (Rắn)', 'Ngọ (Ngựa)', 'Mùi (Dê)',
      'Thân (Khỉ)', 'Dậu (Gà)', 'Tuất (Chó)', 'Hợi (Lợn)',
    ];
    return animals[(year - 4) % 12];
  }
}
