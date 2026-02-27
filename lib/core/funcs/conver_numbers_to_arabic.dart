String  convertEnglishNumbersToArabic(String englishNumber) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  StringBuffer arabicNumber = StringBuffer();
  for (int i = 0; i < englishNumber.length; i++) {
    int digit = int.tryParse(englishNumber[i]) ?? -1; // Convert character to int
    if (digit >= 0 && digit <= 9) {
      arabicNumber.write(arabicNumerals[digit]);
    } else {
      arabicNumber.write(englishNumber[i]); // Append non-numeric characters unchanged
    }
  }
  return arabicNumber.toString();
}