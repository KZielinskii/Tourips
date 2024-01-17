import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/widgets/widget.dart';

import '../add_event/add_event_screen.dart';


const LatLng startPosition = LatLng(52, 20);
const Duration updateInterval = Duration(seconds: 5);

class MapScreen extends StatefulWidget {
  final AddEventView addEventView;

  const MapScreen({super.key, required this.addEventView});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  Map<String, Marker> _markers = {};
  List<LatLng> _points = [];
  late Timer _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _locationUpdateTimer = Timer.periodic(updateInterval, (Timer timer) {
      _updateCurrentLocation();
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz trasę', style: TextStyle(color: Colors.white),),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        polylines: _polylines,
        markers: _markers.values.toSet(),
        onTap: _onMapTap,
        initialCameraPosition: const CameraPosition(
          target: startPosition,
          zoom: 10.0,
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _removeLastPoint();
              },
              heroTag: 'removeButtonHeroTag',
              backgroundColor: Colors.red,
              icon: const Icon(Icons.remove),
              label: const Text('Usuń'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _saveRoute();
              },
              heroTag: 'saveButtonHeroTag',
              backgroundColor: Colors.green,
              icon: const Icon(Icons.save),
              label: const Text('Zapisz'),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      addMarker(
          'point${_markers.length + 1}',
          location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
      _points.add(location);
      _calculateAndDrawRoute();
    });
  }

  void addMarker(String id, LatLng location, {required BitmapDescriptor icon}) {
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: location.toString()),
      draggable: true,
      icon: icon,
      onDragEnd: (newPosition) => _onMarkerDragEnd(id, newPosition),
    );
    _markers[id] = marker;
  }

  void _onMarkerDragEnd(String markerId, LatLng newPosition) {
    setState(() {
      _points[_markers.keys.toList().indexOf(markerId)] = newPosition;
      _calculateAndDrawRoute();
    });
  }

  void _calculateAndDrawRoute() {
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: _points,
      color: Colors.blue,
      width: 5,
    ));
  }

  void _removeLastPoint() {
    if (_points.isNotEmpty) {
      setState(() {
        var lastMarkerKey = _markers.keys.toList().last;
        _markers.remove(lastMarkerKey);
        _points.removeLast();
        _calculateAndDrawRoute();
      });
    }
  }

  void _getCurrentLocation() async {
    try {
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      addMarker('currentLocation', currentLocation,
          icon: await iconDescriptor("assets/images/user_localization.png"));
      setState(() {
        mapController = mapController;
      });
      mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
    } catch (e) {
      print('Error: $e');
    }
  }

  void _updateCurrentLocation() async {
    try {
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      addMarker('currentLocation', currentLocation,
          icon: await iconDescriptor("assets/images/user_localization.png"));
      setState(() {
        mapController = mapController;
      });
    } catch (e) {
      print('Error: $e');
    }
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

  void _saveRoute() async {
    if(_points.isEmpty) {
      createSnackBarError('Nie wybrano żandego punktu!', context);
    }
    else {
      widget.addEventView.doneMap = true;
      widget.addEventView.setPoints(_points);
      Navigator.pop(context);
    }

  }
}

