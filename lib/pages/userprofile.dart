import 'package:cic_production_pi/models/User.dart';
import 'package:cic_production_pi/pages/loginpage.dart';
import 'package:cic_production_pi/pages/prodrec.dart';
import 'package:cic_production_pi/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  static const routeName = 'userprofile';
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

// void _logoutaction(Function logout) async {
//   Map<String, dynamic> sucessInformation;
//   sucessInformation = await logout();
//   if (sucessInformation['success']) {
//     print('logout success');
//     // Navigator.push(
//     //     context, MaterialPageRoute(builder: (context) => LoginPage()));
//     //Navigator.popUntil(context, (route) => route.isFirst);
//     Navigator.pushNamedAndRemoveUntil(
//         context, 'loginpage', (Route<dynamic> route) => false);
//   }
// }

void _logout(UserData users, BuildContext context) {
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
              'ยืนยันการทำรายการ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              'ต้องการออกจากระบบใช่หรือไม่ ?',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Colors.red.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () async {
                      Map<String, dynamic> sucessInformation;
                      sucessInformation = await users.logout();
                      if (sucessInformation['success']) {
                        print('logout success');
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => LoginPage()));
                        //Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushNamedAndRemoveUntil(context, 'loginpage',
                            (Route<dynamic> route) => false);
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => LoginPage()));
                      }
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

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final UserData users = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
              onPressed: () {
                _logout(users, context);
              },
              icon: Icon(Icons.exit_to_app))
        ],
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
