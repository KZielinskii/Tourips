import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DisplayMapScreen extends StatefulWidget {
  final List<LatLng> routePoints;

  const DisplayMapScreen({super.key, required this.routePoints});

  @override
  _DisplayMapScreenState createState() => _DisplayMapScreenState();
}

class _DisplayMapScreenState extends State<DisplayMapScreen> {
  late GoogleMapController mapController;
  Position? currentPosition;
  late Timer locationUpdateTimer;
  late BitmapDescriptor locationIcon;

  @override
  void initState() {
    super.initState();
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
          zoom: 15,
        ),
        markers: _buildMarkers(widget.routePoints),
        polylines: _buildPolylines(widget.routePoints),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _moveToCurrentLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Set<Marker> _buildMarkers(List<LatLng> points) {
    Set<Marker> markers = <Marker>{};
    for (int i = 0; i < points.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('point$i'),
          position: points[i],
          infoWindow: InfoWindow(title: 'Point $i'),
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

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    Set<Polyline> polylines = <Polyline>{};
    if (points.length > 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.blue,
          width: 5,
        ),
      );
    }
    return polylines;
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
      mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
      ));
    }
  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    super.dispose();
  }
}
