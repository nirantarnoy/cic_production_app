import 'dart:async';

import 'package:cic_production_pi/models/Machinemodel.dart';
import 'package:cic_production_pi/models/ProdrecstatusModel.dart';
import 'package:cic_production_pi/models/Prorecmodel.dart';
import 'package:cic_production_pi/providers/machine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ProdrecPage extends StatefulWidget {
  const ProdrecPage({super.key});

  @override
  State<ProdrecPage> createState() => _ProdrecPageState();
}

class _ProdrecPageState extends State<ProdrecPage> {
  final TextEditingController _machinecontroller = TextEditingController();
  final TextEditingController _carcontroller = TextEditingController();
  final TextEditingController _wocontroller = TextEditingController();
  final TextEditingController _itemidcontroller = TextEditingController();
  final TextEditingController _woitemcontroller = TextEditingController();
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
      _wocontroller.text = '';
      _woitemcontroller.text = '';
      _qtycontroller.text = '';
      _itemidcontroller.text = '';

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
        } else {
          //_showScanError('รหัสเครื่องไม่ถูกต้อง หรือ ไม่พบข้อมูล');
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

  void _showScanError(String error) {
    _clearAll();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Icon(
                Icons.mood_bad_outlined,
                size: 32,
                color: Colors.red,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'พบข้อผิดพลาด',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                child: Text(
                  'ไม่พบรายการเครื่องจักรนี้',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'ตกลง',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildqtytextfield() {
    return TextField(
      controller: _qtycontroller,
      decoration: InputDecoration(),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      onSubmitted: (String? value) {
        setState(() {
          _qtycontroller.text = value!;
          if (_machinecontroller.text.isNotEmpty &&
              _wocontroller.text.isNotEmpty &&
              _qtycontroller.text.isNotEmpty) {
            _readytosave = 1;
          } else {
            _readytosave = 0;
          }
        });
      },
    );
  }

  void _fetchMachinedata() async {
    if (_machinecontroller.text != '') {
      EasyLoading.show(status: 'กําลังโหลด...');
      List<MachineModel> res =
          await Provider.of<MachineData>(context, listen: false)
              .fetchMachineData(_machinecontroller.text);
      EasyLoading.dismiss();
      if (res.length > 0) {
        print('has machine');
        setState(() {
          _wocontroller.text = res[0].prod_no;
          _woitemcontroller.text = res[0].item_code;
          _itemidcontroller.text = res[0].item_id;
        });
      } else {
        print('no machine');
        _clearAll();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Icon(
                    Icons.mood_bad_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'พบข้อผิดพลาด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'ไม่พบรายการเครื่องจักรนี้',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }
    } else {}
  }

  void _fetchCardata() async {
    if (_carcontroller.text != '') {
      EasyLoading.show(status: 'กําลังโหลด...');
      bool res = await Provider.of<MachineData>(context, listen: false)
          .fetchCarData(_carcontroller.text);
      EasyLoading.dismiss();
      if (res == true) {
      } else {
        setState(() {
          _carcontroller.text = '';
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Icon(
                    Icons.mood_bad_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'พบข้อผิดพลาด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'ไม่พบรายการรถรหัสนี้',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }
    } else {}
  }

  void _saveDataConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Icon(
                Icons.question_mark_outlined,
                size: 32,
                color: Colors.red,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ยืนยันการทำรายการ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'ต้องการบันทึกข้อมูลใช่หรือไม่ ?',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () {
                        _saveData();
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'ใช่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: MaterialButton(
                      color: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'ไม่ใช่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() async {
    List<ProdrecModel> _listdatasave = [];
    ProdrecModel data = ProdrecModel(
      itemid: _itemidcontroller.text,
      machine_no: _machinecontroller.text,
      qty: _qtycontroller.text,
      wagon_no: _carcontroller.text,
      workorder_no: _wocontroller.text,
    );

    _listdatasave.add(data);
    EasyLoading.show(status: 'กําลังบันทึก...');
    List<ProdrecstatusModel> res =
        await Provider.of<MachineData>(context, listen: false)
            .addProdrecData(_listdatasave);
    EasyLoading.dismiss();
    if (res.length > 0) {
      if (res[0].status == '1') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Icon(
                    Icons.check_circle,
                    size: 32,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'บันทึกข้อมูลสําเร็จ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'บันทึกข้อมูลเรียบร้อยแล้ว',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
        _clearAll();
      } else if (res[0].status == '0') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Icon(
                    Icons.mood_bad_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'พบข้อผิดพลาด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'บันทึกข้อมูลไม่สําเร็จ กรุณาลองใหม่',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      } else if (res[0].status == '100') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Icon(
                    Icons.mood_bad_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'แจ้งการทำงาน',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 15.0, bottom: 8.0, left: 15.0),
                    child: Text(
                      'ส่งมอบยอดผลิตครบแล้ว',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    child: _wocontroller.text != ''
                        ? Text(
                            '${_wocontroller.text}',
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
                    child: _woitemcontroller.text != ''
                        ? Text(
                            '${_woitemcontroller.text}',
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
              child: GestureDetector(
                onTap: () {
                  _readytosave == 1 ? _saveDataConfirm(context) : null;
                },
                child: Container(
                  height: 60,
                  color: _readytosave == 1 ? Colors.green : Colors.grey,
                  child: Center(
                      child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
