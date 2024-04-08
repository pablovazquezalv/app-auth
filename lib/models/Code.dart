class Code {
  final int id;
  final String code;
  //https postgresql
  final bool status;
  //https mysql
  // final int status;
  final int user_id;
  final int expiration_time;
  final DateTime created_at;
  final DateTime updated_at;

  Code({
    required this.id,
    required this.code,
    required this.status,
    required this.user_id,
    required this.expiration_time,
    required this.created_at,
    required this.updated_at,
  });

  factory Code.fromJson(Map<String, dynamic> json) {
    return Code(
      id: json['id'],
      code: json['code'],
      status: json['status'],
      user_id: json['user_id'],
      expiration_time: json['expiration_time'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }
}
