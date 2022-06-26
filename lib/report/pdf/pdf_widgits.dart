import 'package:pdf/widgets.dart';

Widget pdfTableText(String text, [int? maxLen]) {
  if (maxLen != null && text.length > maxLen) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(text.substring(0, maxLen)),
    );
  }
  return Padding(
    padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2),
    child: Text(text),
  );
}
