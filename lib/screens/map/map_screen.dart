import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng startPosition = LatLng(25, 55);

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  Map<String, Marker> _markers = {};
  List<LatLng> _points = [];
  bool selectingStart = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz trasę'),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                selectingStart = true;
              });
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.start),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                selectingStart = false;
              });
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.flag),
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
      if (selectingStart) {
        addMarker('start', location);
        _points.clear();
        _points.add(location);
      } else {
        addMarker('end', location);
        _points.add(location);
        _calculateAndDrawRoute();
      }
    });
  }

  void addMarker(String id, LatLng location) {
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: location.toString()),
    );
    _markers[id] = marker;
  }

  void _calculateAndDrawRoute() {
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      points: _points,
      color: Colors.blue,
      width: 5,
    ));
  }
}
