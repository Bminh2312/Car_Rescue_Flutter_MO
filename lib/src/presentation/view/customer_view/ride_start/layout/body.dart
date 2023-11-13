import 'dart:async';
import 'dart:ui' as ui;
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/elements/round_button.dart';
import 'package:CarRescue/src/presentation/view/customer_view/driver_details/driver_details_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/profile/profile_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/ride_start/layout/widgets/ride_selection_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../layout/profile_widget.dart';
import 'widgets/ride_alert_dialogue.dart';

class RideStartBody extends StatefulWidget {
  @override
  State<RideStartBody> createState() => RideStartBodyState();
}

class RideStartBodyState extends State<RideStartBody> {
  final Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor? destinationIcon;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future setSourceAndDestinationIcons() async {
    final Uint8List icon1 =
        await getBytesFromAsset('assets/images/marker.png', 240);

    destinationIcon = await BitmapDescriptor.fromBytes(icon1);
    setState(() {});
    return Future.value(true);
  }

  @override
  void initState() {
    setSourceAndDestinationIcons().then((value) {
      markers.addAll([
        Marker(
            markerId: const MarkerId('2'),
            position: const LatLng(37.42796133580664, -122.085749655962),
            icon: destinationIcon!),
      ]);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      rideArrivedDialog(context);
    });
    print(markers.length);
    return Stack(children: [
      GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        mapToolbarEnabled: false,
        markers: markers,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      SlidingUpPanel(
        minHeight: 400,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        panel: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xffE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Trip to Destination",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                      text: "4.5 km",
                      color: FrontendConfigs.kIconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              ProfileWidget(
                onTapped: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DriverDetailsView()));
                },
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              RideSelectionWidget(
                icon: 'assets/svg/pickup_icon.svg',
                title: 'Pick up Location',
                body: '089 Stark Gateway',
                onPressed: () {},
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: DottedLine(
                  direction: Axis.vertical,
                  lineLength: 30,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.black,
                  dashRadius: 2.0,
                  dashGapLength: 4.0,
                  dashGapRadius: 0.0,
                ),
              ),
              RideSelectionWidget(
                icon: 'assets/svg/location_icon.svg',
                title: 'Drop off Location',
                body: '92676 Orion Meadows',
                onPressed: () {},
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                color: FrontendConfigs.kIconColor,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundButton(
                    icon: 'assets/svg/message.svg',
                    color: FrontendConfigs.kPrimaryColor,
                    svgColor: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  RoundButton(
                    icon: 'assets/svg/telephone_icon.svg',
                    color: FrontendConfigs.kPrimaryColor,
                    svgColor: Colors.white,
                    onPressed: () {},
                  )
                ],
              ),
            ],
          ),
        ),
      )
    ]);
  }
}
