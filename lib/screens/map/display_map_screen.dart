import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DisplayMapScreen extends StatelessWidget {
  final List<LatLng> routePoints;

  const DisplayMapScreen({super.key, required this.routePoints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trasa:', style: TextStyle(
          color: Colors.white,
        ),),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: routePoints.isNotEmpty ? routePoints.first : const LatLng(0, 0),
          zoom: 15,
        ),
        markers: _buildMarkers(routePoints),
        polylines: _buildPolylines(routePoints),
        onMapCreated: (GoogleMapController controller) {},
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
    return markers;
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
}
