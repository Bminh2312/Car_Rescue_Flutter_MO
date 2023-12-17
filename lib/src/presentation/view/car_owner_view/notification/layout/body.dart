import 'package:CarRescue/main.dart';
import 'package:CarRescue/src/models/notification.dart';
import 'package:CarRescue/src/providers/firebase_message_provider.dart';
import 'package:CarRescue/src/utils/api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'widgets/notification_card.dart';
import './widgets/filter_button.dart';

class NotificationList extends StatefulWidget {
  final String accountId;

  const NotificationList({Key? key, required this.accountId}) : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<Notify>? _notifications;

  Future<void> loadNotifyList() async {
    try {
      List<Notify> notifications =
          await AuthService().getAllNotiList(widget.accountId);

      setState(() {
        _notifications = notifications;
      });
      print('Number of notifications: ${notifications.length}');
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await loadNotifyList();
  }

  @override
  void initState() {
    super.initState();
    loadNotifyList();
    print(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: <Widget>[
            // Notifications List
            Expanded(
              child: _notifications != null
                  ? _notifications!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/notification.png'),
                              SizedBox(
                                height: 20,
                              ),
                              Text('Không có thông báo.'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications!.length,
                          itemBuilder: (context, index) {
                            return NotificationCard(
                                notification: _notifications![index]);
                          },
                        )
                  : Center(
                      child: CircularProgressIndicator(),
                    ), // You can replace this with any loading indicator or message
            ),
          ],
        ),
      ),
    );
  }
}
