class ProdrecModel {
  final String machine_no;
  final String workorder_no;
  final String itemid;
  final String wagon_no;
  final String qty;
  final String? emp_shift_id;
  final String? emp_work_shift_id;

  ProdrecModel({
    required this.machine_no,
    required this.workorder_no,
    required this.itemid,
    required this.wagon_no,
    required this.qty,
    this.emp_shift_id,
    this.emp_work_shift_id,
  });
}
