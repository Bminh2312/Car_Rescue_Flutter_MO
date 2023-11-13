import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/view/customer_view/chat_with_driver/layout/widget/build_appbar.dart';
import 'package:CarRescue/src/presentation/view/customer_view/chat_with_driver/layout/widget/chat_widget.dart';

import '../../../../../models/message.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({Key? key}) : super(key: key);

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

TextEditingController _controller = TextEditingController();
final List<Message> messages = [
  Message(0,
      "But I may not go if the weather is bad. So lets see the weather condition 😀"),
  Message(1, "I suppose I am."),
  Message(2,
      "But I may not go if the weather is bad. So lets see the weather condition 😀"),
  Message(3, "I suppose I am."),
];

class _ChatViewBodyState extends State<ChatViewBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 40,
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10.0);
            },
            reverse: false,
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              Message m = messages[index];
              if (m.user == 0) {
                return MessageRowWidget(
                  current: true,
                  message: m,
                );
              }
              return MessageRowWidget(
                current: false,
                message: m,
              );
            },
          ),
        ),
        BottomBarWidget(controller: _controller)
      ],
    );
  }
}
