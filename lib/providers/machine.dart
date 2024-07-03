import 'dart:convert';

import 'package:cic_production_pi/models/Machinemodel.dart';
import 'package:cic_production_pi/models/Wagonmodel.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MachineData extends ChangeNotifier {
  final String url_to_findmachine =
      "http://app.cic-production-wip.net/api/machineasspi/findmachineno";
  final String url_to_findcar =
      "http://app.cic-production-wip.net/api/machineasspi/findwagonno";

  late List<WagonModel> _wagonlist;
  List<WagonModel> get wagonlist => _wagonlist;

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
}
