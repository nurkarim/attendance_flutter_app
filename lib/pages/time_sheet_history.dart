import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hs_attendance/models/Timesheet.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:http/http.dart' as http;

class TimeSheetHistory extends StatefulWidget {
  const TimeSheetHistory({Key? key}) : super(key: key);

  @override
  _TimeSheetHistoryState createState() => _TimeSheetHistoryState();
}

class _TimeSheetHistoryState extends State<TimeSheetHistory> {
  bool showSpinner = false;
  List<Timesheet> _timeSheet = [];

  void _getSelectedRowInfo(dynamic name, dynamic price) {
    print('Name:$name  price: $price');
  }

  void _getTimeSheetHistory() async {
    try {
      setState(() {
        showSpinner = true;
      });
      http.Response response = await Network().getData('/time_sheet');
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });
        var data = jsonDecode(response.body);
        var value = data['data'];
        // List <Timesheet> list=value;
        setState(() {
          for (var item in value) {
            //print(item);
            setState(() {
              _timeSheet.add(Timesheet(
                  item['id'].toString(),
                  item['date'].toString(),
                  item['in_time'].toString(),
                  item['out_time'].toString(),
                  item['total_hour'].toString(),
                  item['total_late'].toString(),
              ));
              showSpinner = false;
            });
          }
          // _timeSheet = value;
        });
      }
      setState(() {
        showSpinner = false;
      });
    } catch (ex) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  void initState() {
    _getTimeSheetHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Time Sheet")),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30.0,
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'In Time',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Out Time',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Hour',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Late',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              rows: _timeSheet
                  .map(
                    (timeSheet) => DataRow(
                      cells: [
                        DataCell(
                          Center(child: Text(timeSheet.dateName)),
                        ),
                        DataCell(Center(child: Text(timeSheet.inTime))),
                        DataCell(Center(child: Text(timeSheet.outTime))),
                        DataCell(Center(
                            child: Text(
                          timeSheet.TotalHour,
                        ))),
                        DataCell(Center(
                            child: Text(
                              timeSheet.totalLate,
                            ))),
                        DataCell(
                            Center(
                              child: Text("View"),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: new Icon(Icons.photo),
                                          title: new Text('Photo'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(Icons.music_note),
                                          title: new Text('Music'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(Icons.videocam),
                                          title: new Text('Video'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(Icons.share),
                                          title: new Text('Share'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(Icons.share),
                                          title: new Text('Share'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });

                            }),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}


