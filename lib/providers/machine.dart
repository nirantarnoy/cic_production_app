import 'dart:convert';

import 'package:cic_production_pi/models/Machinemodel.dart';
import 'package:cic_production_pi/models/ProdrecstatusModel.dart';
import 'package:cic_production_pi/models/Prorecmodel.dart';
import 'package:cic_production_pi/models/Wagonmodel.dart';
import 'package:cic_production_pi/models/Worktranslist.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MachineData extends ChangeNotifier {
  final String url_to_findmachine =
      "http://app.cic-production-wip.net/api/machineasspi/findmachineno";
  final String url_to_findcar =
      "http://app.cic-production-wip.net/api/machineasspi/findwagonno";
  final String url_to_add_receive =
      "http://app.cic-production-wip.net/api/machineasspi/addreceive";

  final String url_to_trans_list =
      "http://app.cic-production-wip.net/api/machineasspi/translist";

  late List<WagonModel> _wagonlist;
  List<WagonModel> get wagonlist => _wagonlist;

  late List<Worktranslist> _worktranslist;
  List<Worktranslist> get worktranslist => _worktranslist;

  set worktranslist(List<Worktranslist> val) {
    _worktranslist = val;
    notifyListeners();
  }

  set wagonlist(List<WagonModel> val) {
    _wagonlist = val;
    notifyListeners();
  }

  Future<List<MachineModel>> fetchMachineData(String machinecode) async {
    List<MachineModel> data = [];
    final Map<String, dynamic> machine_data = {
      'machine_no': machinecode,
      'emp_no': '',
    };

    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_findmachine),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(machine_data));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);

        if (res == null) {
          notifyListeners();
          return data;
        }
        //print('res data login is ${res}');

        for (var i = 0; i < res['data'].length; i++) {
          final MachineModel user = MachineModel(
            id: res['data'][i]['id'].toString(),
            machine_code: machinecode,
            item_id: res['data'][i]['itemid'].toString(),
            item_code: res['data'][i]['itemname'].toString(),
            prod_no: res['data'][i]['workorder_no'].toString(),
            prod_qty: res['data'][i]['qty'].toString(),
            prod_id: '',
          );

          data.add(user);
        }

        return data;
      } else {
        return data;
      }
    } catch (err) {
      print(err);
      return data;
    }
    // return machineList;
  }

  Future<bool> fetchCarData(String car_no) async {
    final Map<String, dynamic> machine_data = {
      'wagon_no': car_no,
    };

    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_findcar),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(machine_data));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<WagonModel> data = [];
        if (res == null) {
          notifyListeners();
          return false;
        }
        //print('res data login is ${res}');

        for (var i = 0; i < res['data'].length; i++) {
          final WagonModel _item = WagonModel(
            id: res['data'][i]['id'].toString(),
            wagon_no: res['data'][i]['wagon_no'].toString(),
            status: res['data'][i]['status'].toString(),
          );

          data.add(_item);
        }

        wagonlist = data;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
    // return machineList;
  }

  Future<List<ProdrecstatusModel>> addProdrecData(
      List<ProdrecModel> _listdata) async {
    List<ProdrecstatusModel> _data = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String emp_no = prefs.getString('user_no').toString();
    String emp_shift_id = prefs.getString('emp_shift_id').toString();
    String emp_work_shift_id = prefs.getString('emp_work_shift_id').toString();

    final jsonObj = _listdata
        .map((e) => {
              'emp_no': emp_no,
              'emp_shif_id': emp_shift_id,
              'emp_work_shift_id': emp_work_shift_id,
              'machine_no': e.machine_no,
              'wagon_no': e.wagon_no,
              'workorder_no': e.workorder_no,
              'itemid': e.itemid,
              'qty': e.qty
            })
        .toList();

    final Map<String, dynamic> rec_data = {
      'data': jsonObj,
    };
    // print("data for save is ${rec_data}");
    // return false;
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_add_receive),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(rec_data));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);

        if (res == null) {
          _data.add(ProdrecstatusModel(
            status: '0',
            message: 'No Data',
          ));
          notifyListeners();
          return _data;
        }
        if (res['status'] == 1) {
          print('result is ${res}');
          _data.add(ProdrecstatusModel(
            status: '1',
            message: 'Save Success',
          ));
          notifyListeners();
          print('save ok');
          return _data;
        } else if (res['status'] == 100) {
          _data.add(ProdrecstatusModel(
            status: '100',
            message: 'Over Quantity',
          ));
          notifyListeners();
          return _data;
        } else {
          return _data;
        }
      } else {
        return _data;
      }
    } catch (err) {
      print(err);
      return _data;
    }
  }

  Future<List<Worktranslist>> fetchTranslist() async {
    List<Worktranslist> data = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String emp_no = prefs.getString('user_no').toString();
    final Map<String, dynamic> filter_data = {
      'emp_no': emp_no,
    };
    print("data filter is ${filter_data}");
    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_trans_list),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(filter_data));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);

        if (res == null) {
          notifyListeners();
          return data;
        }
        print('res data login is ${res}');

        for (var i = 0; i < res['data'].length; i++) {
          final Worktranslist _item = Worktranslist(
            wo_no: res['data'][i]['workorder_no'].toString(),
            machine_no: res['data'][i]['machine_no'].toString(),
            qty: res['data'][i]['qty'].toString(),
            wagon_no: res['data'][i]['wagon_no'].toString(),
          );

          data.add(_item);
        }
        worktranslist = data;
        notifyListeners();
        return data;
      } else {
        return data;
      }
    } catch (err) {
      print(err);
      return data;
    }
    // return machineList;
  }
}
