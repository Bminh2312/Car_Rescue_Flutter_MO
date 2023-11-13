import 'package:CarRescue/src/models/top_up_selection.dart';

import '../models/person_card.dart';

class Utils {
  static List<PersonCardModel> profileCard = [
    PersonCardModel(
        profileImage: 'assets/images/profile.png',
        name: 'Harry Potter',
        details: 'Lorem ipsum dolor sit amet, consectetur',
        time: '12:20'),
    PersonCardModel(
        profileImage: 'assets/images/profile_one.png',
        name: 'Harry Potter',
        details: 'Lorem ipsum dolor sit amet, consectetur',
        time: '12:20'),
    PersonCardModel(
        profileImage: 'assets/images/profile_two.png',
        name: 'Harry Potter',
        details: 'Lorem ipsum dolor sit amet, consectetur',
        time: '12:20'),
    PersonCardModel(
        profileImage: 'assets/images/profile_three.png',
        name: 'Harry Potter',
        details: 'Lorem ipsum dolor sit amet, consectetur',
        time: '12:20'),
    PersonCardModel(
        profileImage: 'assets/images/profile.png',
        name: 'Harry Potter',
        details: 'Lorem ipsum dolor sit amet, consectetur',
        time: '12:20'),
  ];
  static List<TopUpSelectionModel> topUpList = [
    TopUpSelectionModel(
      "\$10",
    ),
    TopUpSelectionModel(
      "\$20",
    ),
    TopUpSelectionModel(
      "\$50",
    ),
    TopUpSelectionModel(
      "\$100",
    ),
    TopUpSelectionModel(
      "\$120",
    ),
    TopUpSelectionModel(
      "\$150",
    ),
    TopUpSelectionModel(
      "\$200",
    ),
    TopUpSelectionModel(
      "\$300",
    )
  ];
}
