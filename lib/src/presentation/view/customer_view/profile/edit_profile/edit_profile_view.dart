import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/customer_view/profile/edit_profile/widget/edit_profile.dart';
import 'package:flutter/material.dart';

class EditProfileViewCustomer extends StatelessWidget {
  final String id;
  final String accountId;
  const EditProfileViewCustomer(
      {Key? key, required this.id, required this.accountId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Chỉnh sửa thông tin',
        showText: true,
      ),
      body: EditProfileBody(
        userId: this.id,
        accountId: this.id,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
      ),
    );
  }
}
