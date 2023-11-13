import 'package:CarRescue/src/presentation/elements/custom_appbar.dart';
import 'package:CarRescue/src/presentation/view/car_owner_view/edit_profile/layout/edit_profile.dart';
import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({
    Key? key,
    required this.userId,
    required this.accountId,
  }) : super(key: key);
  final String userId;
  final String accountId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        text: 'Chỉnh sửa thông tin',
        showText: true,
      ),
      body: EditProfileBody(
        userId: userId,
        accountId: accountId,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
      ),
    );
  }
}
