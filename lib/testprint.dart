import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class TestPrint {
  TestPrint({this.content = 'sample'});
  String content = '';
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  sample() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printNewLine();
        bluetooth.printCustom(content, 1, 1);
        bluetooth.paperCut();
      }
    });
  }
}
