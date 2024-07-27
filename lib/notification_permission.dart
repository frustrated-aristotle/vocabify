import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionPage extends StatefulWidget {
  @override
  _NotificationPermissionPageState createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Notification Permission'),
          content: Text('This app needs notification access to send you updates.'),
          actions: <Widget>[
            TextButton(
              child: Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to the previous page
              },
            ),
            TextButton(
              child: Text('Allow'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.notification.request();
                Navigator.of(context).pop(); // Go back to the previous page
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(); // If already granted, go back to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Permission'),
      ),
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator while requesting permission
      ),
    );
  }
}
