import 'package:flutter/material.dart';
import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';

import '../../../../configuration/frontend_configs.dart';
import 'layout/body.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Daniel Austin",
          style: TextStyle(
              color: FrontendConfigs.kPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(100),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: FrontendConfigs.kPrimaryColor)),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: FrontendConfigs.kPrimaryColor,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      ),
      body: ChatViewBody(),
    );
  }
}
