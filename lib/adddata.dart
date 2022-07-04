import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posprinter/testprint.dart';
import 'package:http/http.dart' as http;

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({Key? key}) : super(key: key);

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  BlueThermalPrinter bluettoth = BlueThermalPrinter.instance;
  var key = GlobalKey<FormState>();
  String content = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADD DATA')),
      body: Form(
        key: key,
        child: Column(
          children: [
            TextFormField(
              onChanged: (val) {
                content = val;
              },
              onSaved: (val) {
                content = val!;
              },
            ),
            TextButton(
                onPressed: () {
                  key.currentState!.save();
                  TestPrint(content: content).sample();
                },
                child: Text('Print now')),
            TextButton(
                onPressed: () async {
                  var res = await http.get(Uri.parse(
                      'https://itpikrc.org.in/mandapam/public/Appcontroller/recent_registerd_partner'));
                  var resp = json.decode(res.body);
                  var data = resp['data'];
                  var d = data.toString();
                  var temp = d.replaceAll('{', '');
                  temp = temp.replaceAll('}', '');
                  temp = temp.replaceAll('[', '');
                  temp = temp.replaceAll(']', '');
                  List<String> list = temp.split(',');

                  print(temp);
                  await Future.forEach(list, (String string) {
                    bluettoth.printNewLine();
                    bluettoth.printCustom(string, 1, 1);
                  });
                  bluettoth.paperCut();
                },
                child: Text('API PRINT TEST')),
            TextButton(
                onPressed: () async {
                  var picker = ImagePicker();
                  var img = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 1);
                  // print(temp);

                  bluettoth.printImage(img!.path);
                  bluettoth.paperCut();
                },
                child: Text('pic print test'))
          ],
        ),
      ),
    );
  }
}
