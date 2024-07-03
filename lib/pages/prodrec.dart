import 'dart:async';

import 'package:cic_production_pi/models/Machinemodel.dart';
import 'package:cic_production_pi/providers/machine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProdrecPage extends StatefulWidget {
  const ProdrecPage({super.key});

  @override
  State<ProdrecPage> createState() => _ProdrecPageState();
}

class _ProdrecPageState extends State<ProdrecPage> {
  final TextEditingController _machinecontroller = TextEditingController();
  final TextEditingController _carcontroller = TextEditingController();
  final TextEditingController _woqtycontroller = TextEditingController();
  final TextEditingController _woitemqtycontroller = TextEditingController();
  final TextEditingController _qtycontroller = TextEditingController();

  late String _scanResult = 'No scan yet';
  static const MethodChannel _channel = MethodChannel('keyence_scanner');
  late int _readytosave = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(new Duration(seconds: 2), (timer) {
      // debugPrint(timer.tick.toString());
      startScan();
    });
  }

  void _clearAll() {
    setState(() {
      _machinecontroller.text = '';
      _carcontroller.text = '';
      _woqtycontroller.text = '';
      _woitemqtycontroller.text = '';
      _qtycontroller.text = '';

      _readytosave = 0;
      stopScan();
    });
  }

  Future<void> startScan() async {
    if (_machinecontroller.text == '') {
      final String result = await _channel.invokeMethod('startScan');
      String _prefix = '';
      if (result != '') {
        _prefix = result.substring(0, 1);
        if (_prefix == 'H') {
          if (_machinecontroller.text != '') {
            print('Machine Already has scan data');
          } else {
            setState(() {
              _machinecontroller.text = result;
              _fetchMachinedata();
            });
          }
        }
      }
    }
    if (_carcontroller.text == '') {
      final String result = await _channel.invokeMethod('startScan');
      String _prefix = '';
      if (result != '') {
        _prefix = result.substring(0, 1);
        if (_prefix == 'C') {
          if (_carcontroller.text != '') {
            print('Car Already has scan data');
          } else {
            if (_machinecontroller.text != '') {
              // has machine scan
              setState(() {
                _carcontroller.text = result;
                _fetchCardata();
              });
            }
          }
        } else {
          print('Invalid Format or Data');
        }
      }
    }

    // print('startScan: $result');
    // return result;
  }

  static Future<String> stopScan() async {
    final String result = await _channel.invokeMethod('stopScan');
    print(result);
    return result;
  }

  Widget _buildqtytextfield() {
    return TextField(
      controller: _qtycontroller,
      decoration: InputDecoration(),
      keyboardType: TextInputType.number,
      onChanged: (String? value) {
        setState(() {
          _qtycontroller.text = value!;
        });
      },
    );
  }

  void _fetchMachinedata() async {
    if (_machinecontroller.text != '') {
      List<MachineModel> res =
          await Provider.of<MachineData>(context, listen: false)
              .fetchMachineData(_machinecontroller.text);
      if (res != null) {
        setState(() {
          _woqtycontroller.text = res[0].prod_no;
          _woitemqtycontroller.text = res[0].item_code;
        });
      }
    } else {}
  }

  void _fetchCardata() async {
    if (_carcontroller.text != '') {
      bool res = await Provider.of<MachineData>(context, listen: false)
          .fetchCarData(_carcontroller.text);
      if (res != true) {
        setState(() {
          _carcontroller.text = '';
        });
      } else {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รับยอด')),
      body: Column(children: <Widget>[
        SizedBox(
          height: 15,
        ),
        Expanded(
          flex: 6,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'รหัสเครื่อง',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _machinecontroller.text != ''
                        ? Text(
                            '${_machinecontroller.text}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'เลขที่ใบสั่ง',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _woqtycontroller.text != ''
                        ? Text(
                            '${_woqtycontroller.text}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'รหัสยาง',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _woitemqtycontroller.text != ''
                        ? Text(
                            '${_woitemqtycontroller.text}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'เลขรถ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _carcontroller.text != ''
                        ? Text(
                            '${_carcontroller.text}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : Icon(
                            Icons.close_outlined,
                            color: Colors.red,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'จำนวนรับ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildqtytextfield(),
                  ),
                ],
              ),
            ),
          ]),
        ),
        Expanded(
          flex: 1,
          child: Row(children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => _clearAll(),
                child: Container(
                  height: 60,
                  color: Colors.red,
                  child: Center(
                      child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                color: Colors.green,
                child: Center(
                    child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
