class User {
  final String id;
  final String person_no;
  final String person_name;
  final String emp_shift_id;
  final String emp_work_shift_id;
  final String emp_work_shift_name;

  User(
      {required this.id,
      required this.person_no,
      required this.person_name,
      required this.emp_shift_id,
      required this.emp_work_shift_id,
      required this.emp_work_shift_name});
}
