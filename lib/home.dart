import 'dart:ffi';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posprinter/adddata.dart';
import 'package:posprinter/testprint.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  String pathImage = '';
  //TestPrint

  @override
  void initState() {
    super.initState();
    initPlatFormState();
  }

  Future<void> initPlatFormState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      //todo
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state : connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth  off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth  on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });
    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
    if (isConnected!) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Printer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Device:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (BluetoothDevice? value) =>
                        setState(() => _device = value),
                    value: _device,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.brown),
                  onPressed: () {
                    initPlatFormState();
                  },
                  child: Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: _connected ? Colors.red : Colors.green),
                  onPressed: _connected ? _disconnect : _connect,
                  child: Text(
                    _connected ? 'Disconnect' : 'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                onPressed: () {
                  TestPrint().sample();
                },
                child:
                    Text('PRINT TEST', style: TextStyle(color: Colors.white)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddDataScreen();
                  }));
                },
                child: Text('Manual', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(child: Text('none')));
    } else {
      _devices.forEach((device) {
        items.add(
          DropdownMenuItem(
            value: device,
            child: Text(device.name!),
          ),
        );
      });
    }
    return items;
  }

  void _connect() {
    print('connect');
    print(_connected);
    print(_device!.name);
    if (_device == null) {
      show('no device selceted');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(_device!).catchError((error) {
            setState(() {
              _connected = false;
              print('err');
            });
          });
          setState(() {
            print('1');
            _connected = true;
          });
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() {
      _connected = false;
    });
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
