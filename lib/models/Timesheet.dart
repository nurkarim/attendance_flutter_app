class Timesheet {
  String id;
  String dateName;
  String inTime;
  String outTime;
  String TotalHour;
  String totalLate;

  Timesheet( this.id,  this.dateName,  this.inTime, this.outTime, this.TotalHour,this.totalLate);

  // factory Timesheet.fromJson(Map<String, dynamic> json) {
  //   return Timesheet(
  //     id: json['id'] as String,
  //     dateName: json['date'] as String,
  //     inTime: json['in_time'] as String,
  //     outTime: json['out_time'] as String,
  //     TotalHour: json['total_hour'] as String,
  //   );
  // }
}