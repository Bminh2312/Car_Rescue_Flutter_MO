import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/layout/repair_layout/body.dart';
import 'package:CarRescue/src/presentation/view/customer_view/service_details/layout/tow_layout/body.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderView extends StatelessWidget {
  final LatLng latLngPick;
  final String addressPick;
  final LatLng latLngDrop;
  final String addressDrop;
  final String distance;
  final String serviceType;
  final String carId;
  const OrderView({Key? key, required this.latLngPick, required this.addressPick, required this.serviceType, required this.latLngDrop, required this.addressDrop, required this.distance, required this.carId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body;
    
    if (serviceType == "Fixing") {
      body = RepairBody(latLng: latLngPick, address: addressPick, carId: carId,);
    } else if (serviceType == "Towing") {
      body = TowBody(latLng: latLngPick, address: addressPick, latLngDrop: latLngDrop, addressDrop: addressDrop, distance: distance, carId: carId,);
    } else {
      // Handle other cases or provide a default body.
      body = Text("Invalid service type");
    }
    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.transparent,
          elevation:0,
          leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
          //  Navigator.of(context).pushReplacement(
          //                   MaterialPageRoute(
          //                       builder: (context) => HomeView(services:serviceType == "repair"?"repair":"tow")),
          //                 );
          Navigator.of(context).pop();
          },
        ),
          title:CustomText(text: 'Đơn đặt',fontSize:16,color:FrontendConfigs.kPrimaryColor,),
          centerTitle:true,
        ),
      body:body,
    );
  }
}