import 'package:flutter/material.dart';
import 'widgets/notification_card.dart';
import './widgets/filter_button.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: 1,
      title: 'Công việc mới',
      content: 'Bạn đã được phân công công việc mới từ quản lí.',
      status: 'Mới',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    NotificationItem(
      id: 2,
      title: 'Đã hoàn thành',
      content: 'Công việc #123 đã hoàn thành.',
      status: 'Hoàn thành',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    NotificationItem(
      id: 3,
      title: 'Đã huỷ',
      content: 'Công việc #123 đã bị huỷ bởi quản lí.',
      status: 'Đã huỷ',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    // Your notification items
  ];

  String selectedFilter = 'Tất cả';

  List<NotificationItem> get filteredNotifications {
    if (selectedFilter == 'Tất cả') {
      return notifications;
    } else {
      return notifications
          .where((notification) => notification.status == selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Filter Container
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FilterButton(
                    'Tất cả', selectedFilter == 'Tất cả', onSelectFilter),
                FilterButton('Mới', selectedFilter == 'Mới', onSelectFilter),
                FilterButton('Hoàn thành', selectedFilter == 'Hoàn thành',
                    onSelectFilter),
                FilterButton(
                    'Đã huỷ', selectedFilter == 'Đã huỷ', onSelectFilter),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(
                    notification: filteredNotifications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void onSelectFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }
}
