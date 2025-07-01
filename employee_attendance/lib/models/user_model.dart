class UserModel {
  final String id;
  final String email;
  final String name;
  final int? site;
  final String employeeId;

  UserModel(
      {required this.id,  
      required this.email,
      required this.name,
      required this.site,
      required this.employeeId});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
        id: data['id'],
        email: data['email'],
        name: data['name'],
        site: data['site'],
        employeeId: data['employee_id']);
  }
}
