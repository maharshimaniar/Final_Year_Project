import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:url_launcher/url_launcher.dart';

import '../Providers/appointmentProvider.dart';
import '../Providers/doctorProvider.dart';
import '../Widgets/doctorListTile.dart';

class DoctorScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<DoctorScreen> {
  String scanResult = '';
  Future<void> scanQRCode() async {
    String cameraScanResult = await scanner.scan();
    setState(() {
      scanResult = cameraScanResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _makePhoneCall(String url) async {
      if (await canLaunch('tel:+91$url')) {
        await launch('tel:+91$url');
      } else {
        print("error");
      }
    }

    final _doctorList = Provider.of<DoctorProvider>(context).doctorList;
    return Scaffold(
        body: Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black,
                  indent: 30,
                  endIndent: 30,
                  thickness: 1 / 5,
                );
              },
              itemCount: _doctorList.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.orangeAccent[100]),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_call,
                          color: Colors.green[700],
                          size: 40,
                        ),
                        Spacer(),
                        Icon(
                          Icons.delete,
                          color: Colors.red[700],
                          size: 40,
                        ),
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                  ),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete Doctor'),
                          content: Text(
                            'Do you want to remove Dr.${_doctorList[index].name}?',
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                            ),
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(ctx).pop(true);
                              },
                            ),
                          ],
                        ),
                      );
                    } else if (direction == DismissDirection.startToEnd) {
                      _makePhoneCall(_doctorList[index].contactNumber);
                    }
                  },
                  onDismissed: (direction) {
                    setState(() {
                      Provider.of<DoctorProvider>(context, listen: false)
                          .deleteDoctor(index);
                      Provider.of<AppointmentProvider>(context, listen: false)
                          .deleteSpecificDoctorAppointment(
                              _doctorList[index].id);
                    });
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${_doctorList[index].name} Deleted Successfully.'),
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: DoctorListTile(
                    doctor: _doctorList[index],
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add),
            onPressed: () async {
              await scanQRCode();
              bool result = Provider.of<DoctorProvider>(context, listen: false)
                  .adddDoctorByQrScan(scanResult);
              if (result) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Doctor added Successfully.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An Error Occured.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }));
  }
}
