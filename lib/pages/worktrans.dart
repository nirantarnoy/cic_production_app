import 'package:cic_production_pi/models/Worktranslist.dart';
import 'package:cic_production_pi/providers/machine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class WorktransPage extends StatefulWidget {
  const WorktransPage({super.key});

  @override
  State<WorktransPage> createState() => _WorktransPageState();
}

class _WorktransPageState extends State<WorktransPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EasyLoading.show(status: 'กําลังบันทึก...');
    Provider.of<MachineData>(context, listen: false).fetchTranslist();
    EasyLoading.dismiss();
  }

  Widget _buildlist(List<Worktranslist> worktranslist) {
    return worktranslist.isEmpty
        ? Center(child: Text('No Data'))
        : Expanded(
            child: ListView.builder(
              itemCount: worktranslist.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(8),
                  color: Colors.green.shade200,
                  child: ListTile(
                    isThreeLine: true,
                    minVerticalPadding: 0,
                    leading: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text('${worktranslist[index].wagon_no}')),
                      ],
                    )),
                    title: Text('${worktranslist[index].wo_no}'),
                    subtitle: Text('${worktranslist[index].machine_no}'),
                    trailing: Text('${worktranslist[index].qty}'),
                  ),
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ประวัติรับยอดผลิต')),
      body: Column(children: [
        Consumer<MachineData>(
          builder: (context, value, child) => _buildlist(value.worktranslist),
        ),
      ]),
    );
  }
}
