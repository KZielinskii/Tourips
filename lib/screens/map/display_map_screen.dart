import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DisplayMapScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final List<String> pointsInfo;

  const DisplayMapScreen({super.key, required this.routePoints, required this.pointsInfo});

  @override
  _DisplayMapScreenState createState() => _DisplayMapScreenState();
}

class _DisplayMapScreenState extends State<DisplayMapScreen> {
  late GoogleMapController mapController;
  Position? currentPosition;
  late Timer locationUpdateTimer;
  late BitmapDescriptor locationIcon;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _calculateAndDrawRoute();
    _getCurrentLocation();
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trasa:',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition != null
              ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
              : widget.routePoints.isNotEmpty
              ? widget.routePoints.first
              : const LatLng(0, 0),
          zoom: 13,
        ),
        markers: _buildMarkers(widget.routePoints),
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveToCurrentLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _calculateAndDrawRoute() async {
    if (widget.routePoints.length < 2) {
      return;
    }

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> newRoutePoints = [];

    for (int i = 0; i < widget.routePoints.length - 1; i++) {
      PointLatLng start = PointLatLng(widget.routePoints[i].latitude, widget.routePoints[i].longitude);
      PointLatLng end = PointLatLng(widget.routePoints[i + 1].latitude, widget.routePoints[i + 1].longitude);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyAR_51lpB8C9jjvZrrs0P-ASYrWhJaB5vk",
        start,
        end,
      );

      if (result.points.isNotEmpty) {
        newRoutePoints.addAll(result.points.map((point) => LatLng(point.latitude, point.longitude)));
      } else {
        print('Error fetching route between points $i and ${i + 1}');
      }
    }

    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: newRoutePoints,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  Set<Marker> _buildMarkers(List<LatLng> points) {
    Set<Marker> markers = <Marker>{};
    for (int i = 0; i < points.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('point$i'),
          position: points[i],
          infoWindow: InfoWindow(title: widget.pointsInfo[i]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Twoja lokalizacja'),
          icon: locationIcon,
        ));
    }

    return markers;
  }

  Future<BitmapDescriptor> iconDescriptor(String name) async {
    try {
      const ImageConfiguration configuration = ImageConfiguration();
      final BitmapDescriptor bitmapDescriptor =
      await BitmapDescriptor.fromAssetImage(configuration, name);
      return bitmapDescriptor;
    } catch (e) {
      print('Error loading image: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      locationIcon = await iconDescriptor("assets/images/user_localization.png");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      print(e);
    }
  }

  void _moveToCurrentLocation() {
    if (currentPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
        10
      ));
    }
  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    super.dispose();
  }
}
