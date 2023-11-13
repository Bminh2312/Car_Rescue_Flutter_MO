import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/presentation/elements/custom_text.dart';
import 'package:CarRescue/src/presentation/view/customer_view/cancel_ride/cancel_ride_view.dart';
import 'package:CarRescue/src/presentation/view/customer_view/driver_arriving/driver_arriving_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:slider_button/slider_button.dart';

class SearchingDrivingBody extends StatefulWidget {
  @override
  State<SearchingDrivingBody> createState() => SearchingDrivingBodyState();
}

class SearchingDrivingBodyState extends State<SearchingDrivingBody> {
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
        await getBytesFromAsset('assets/images/driver_marker.png', 240);

    destinationIcon = await BitmapDescriptor.fromBytes(icon1);
    setState(() {});
    return Future.value(true);
  }

  Timer? _timer;

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
    _timer = Timer(
        const Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const DriverArrivingView())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      Positioned.fill(
        top: 100,
        child: Column(
          children: [
            Container(
                height: 61,
                width: 61,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFF2DBB54),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    "assets/svg/car_icon.svg",
                  ),
                )),
            Transform.translate(
                offset: const Offset(0, -1),
                child: SvgPicture.asset(
                  "assets/svg/polygon.svg",
                  color: Color(0xFF2DBB54),
                )),
            const SizedBox(
              height: 6,
            ),
            CustomText(
              text: "Searching Ride...",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(
              height: 6,
            ),
            CustomText(
              text: "This may take a few seconds...",
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: SliderButton(
          shimmer: true,
          baseColor: Colors.white,
          buttonSize: 45,
          height: 60,
          width: 200,
          backgroundColor: Colors.green,
          action: () {
            _timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CancelRideView()));
          },
          label: const Text(
            ">>> Slide to cancel",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          icon: SvgPicture.asset("assets/svg/cancel_icon.svg"),
        ),
      )
    ]);
  }
}
