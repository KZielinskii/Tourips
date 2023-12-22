import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wybierz trase'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        polylines: _polylines,
        initialCameraPosition: const CameraPosition(
          target: LatLng(51.7592, 19.4559),
          zoom: 10.0,
        ),
        onTap: _addPoint,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _drawRoute,
        child: const Icon(Icons.directions),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _addPoint(LatLng point) {
    setState(() {
      _points.add(point);
    });
  }

  void _drawRoute() {
    if (_points.length > 1) {
      PolylineId id = const PolylineId("route");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: _points,
        width: 3,
      );

      setState(() {
        _polylines.add(polyline);
      });

      _points.clear();
    }
  }
}
