// my_custom_messages.dart
import 'package:timeago/timeago.dart';

class MyCustomMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'ئێستا';
  @override
  String aboutAMinute(int minutes) => '$minutesنزیک خولەکێک ';
  @override
  String minutes(int minutes) => '$minutes خولەک';
  @override
  String aboutAnHour(int minutes) => '$minutes نزیک کاتژمێرێک';
  @override
  String hours(int hours) => '$hours کاتژمێر';
  @override
  String aDay(int hours) => '$hours ڕۆژێک لەمەوپێش';
  @override
  String days(int days) => '$days رۆژ';
  @override
  String aboutAMonth(int days) => '$days نزیک مانگێک';
  @override
  String months(int months) => '$months مانگ';
  @override
  String aboutAYear(int year) => '$year نزیک ساڵێك';
  @override
  String years(int years) => '$years ساڵ';
  @override
  String wordSeparator() => ' ';
}
