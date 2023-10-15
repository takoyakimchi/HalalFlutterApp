import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HalalFoodMapScreen extends StatefulWidget {
  const HalalFoodMapScreen({Key? key}) : super(key: key);

  @override
  _HalalFoodMapScreenState createState() => _HalalFoodMapScreenState();
}

class _HalalFoodMapScreenState extends State<HalalFoodMapScreen> {
  /// 초기화
  @override
  void initState() {
    initialize();
    super.initState();
  }

  /// 초기화
  Future<void> initialize() async {
    _showHalalFoodMarkers();
  }

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5333, 126.998),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};

  List<List<dynamic>> halalShopsList = [
    [LatLng(37.5333, 126.998), "HAJJkoreahalalfood"],
    [LatLng(37.5347, 126.9948), "The Halal Guys Itaewon"],
    [LatLng(37.529, 127.0001), "K.M.F Halal"],
    [LatLng(37.5055, 127.027), "The Halal Guys Gangnam"],
    [LatLng(37.559, 126.986), "Kampungku Restaurant"],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnNearestHalal),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showHalalFoodMarkers() async {
    final GoogleMapController controller = await _controller.future;
    final Position? position = await getCurrentUserLocation();

    if (position != null) {
      final LatLng userLocation = LatLng(position.latitude, position.longitude);
      controller.animateCamera(CameraUpdate.newLatLng(userLocation));

      setState(() {
        _markers.clear();
        for (List subList in halalShopsList) {
          LatLng location = subList[0];
          String name = subList[1];
          _markers.add(
            Marker(
              markerId: MarkerId(location.toString()),
              position: location,
              infoWindow: InfoWindow(title: name),
            ),
          );
        }
      });
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Error'),
            content: const Text('Failed to retrieve current location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<Position?> getCurrentUserLocation() async {
    final PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      try {
        return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print('Error getting current location: $e');
      }
    }
    return null;
  }
}

