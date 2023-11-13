import 'package:flutter/material.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/app_button.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/utils/utils.dart';

class TopUpBody extends StatefulWidget {
  TopUpBody({Key? key}) : super(key: key);

  @override
  State<TopUpBody> createState() => _TopUpBodyState();
}

class _TopUpBodyState extends State<TopUpBody> {
  int currentIndex = -1;

  void setIndex(int i) {
    setState(() {
      currentIndex = i;
    });
  }

  int get getIndex => currentIndex;
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(
                height: 18,
              ),
              CustomText(
                text: 'Enter the amount of top up',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              const SizedBox(
                height: 18,
              ),
              TextFormField(
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hintText: '\$120',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.4),
                    )),
              ),
              const SizedBox(
                height: 18,
              ),
              Wrap(
                children: [
                  ...Utils.topUpList
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              child: Container(
                                height: 57,
                                width: 70,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    color:
                                        getIndex == Utils.topUpList.indexOf(e)
                                            ? Colors.black.withOpacity(0.10)
                                            : Colors.white),
                                child: FittedBox(
                                    child: Center(
                                        child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: CustomText(
                                    text: Utils
                                        .topUpList[Utils.topUpList.indexOf(e)]
                                        .amount,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ))),
                              ),
                              onTap: () {
                                setState(() {
                                  setIndex(Utils.topUpList.indexOf(e));
                                });
                              },
                            ),
                          ))
                      .toList()
                ],
              ),
              Container(
                height: 80,
              ),
              // SizedBox(
              //   height:300,
              //   child: ListView.builder(
              //      shrinkWrap:true,
              //       scrollDirection:Axis.horizontal,
              //       itemCount:Utils.topUpList.length,
              //       itemBuilder: (context, i) {
              //     return Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Wrap(
              //         direction:Axis.horizontal,
              //         children: [,
              //       ]),
              //     );
              //   }),
              // )
              AppButton(onPressed: () {}, btnLabel: "Continue")
            ],
          ),
        ),
      ),
    );
  }
}
