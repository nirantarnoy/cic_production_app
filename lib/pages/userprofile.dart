import 'package:cic_production_pi/models/User.dart';
import 'package:cic_production_pi/pages/prodrec.dart';
import 'package:cic_production_pi/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  static const routeName = '/userprofile';
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

Widget _buildProfile(BuildContext context, List<User> _list) {
  return _list.isEmpty
      ? Center(child: Text('No Data'))
      : Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'รหัสพนักงาน',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
                Expanded(
                    child: Text(
                  '${_list[0].person_no}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'ชื่อ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
                Expanded(
                    child: Text(
                  '${_list[0].person_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'กะพนักงาน',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
                Expanded(
                    child: Text(
                  '${_list[0].emp_shift_id}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                  'กะทำงาน',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
                Expanded(
                    child: Text(
                  '${_list[0].emp_work_shift_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProdrecPage())),
                child: Text(
                  'รับยอดผลิต',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              )),
            )
          ],
        );
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<UserData>(
          builder: (context, value, child) =>
              _buildProfile(context, value.userdata),
        ),
      ),
    );
  }
}
