import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';

import '../../../../../../models/message.dart';

class MessageRowWidget extends StatelessWidget {
  final Message message;
  final bool current;

  const MessageRowWidget(
      {Key? key, required this.message, required this.current})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment:
            current ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            current ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: current ? 30.0 : 20.0),
          Container(
              padding: const EdgeInsets.only(
                bottom: 5,
                right: 5,
              ),
              child: Column(
                  crossAxisAlignment: current
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        constraints: BoxConstraints(
                          minHeight: 40,
                          maxHeight: 250,
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          minWidth: MediaQuery.of(context).size.width * 0.1,
                        ),
                        decoration: BoxDecoration(
                          color: current
                              ? Color(0xFF2DBB54)
                              : FrontendConfigs.kIconColor,
                          borderRadius: current
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 10, bottom: 5, right: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: current
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(
                                  message.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ]))
        ]);
  }
}
