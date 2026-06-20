import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LaptopMapPage extends StatefulWidget {
  const LaptopMapPage({super.key});

  @override
  State<LaptopMapPage> createState() => _LaptopMapPageState();
}

class _LaptopMapPageState extends State<LaptopMapPage> {
  GoogleMapController? _mapController;

  final LatLng _center = const LatLng(13.0805673, 80.1475273); // Chennai as example,

  // Example: 20 zone locations
  final List<LatLng> _zones = [
    const LatLng(13.0805673, 80.1475273),
    const LatLng(13.1182458, 80.2238781),
    const LatLng(13.0842632, 80.1705938),
    const LatLng(13.1198508, 80.1475358),
    const LatLng(13.114213, 80.0475859),
    const LatLng(13.1949951, 80.1642484),
    const LatLng(13.0376327, 80.1443284),
    const LatLng(13.052185, 80.2011021),
    const LatLng(13.0426146, 80.2283541),
    const LatLng(13.0710631, 80.2499452),
    const LatLng(13.0067731, 80.2386858),
    const LatLng(13.0524786, 80.2507552),
    const LatLng(13.0067266, 80.1990727),
    const LatLng(12.9791549, 80.1991723),
    const LatLng(12.9220871, 80.0717559),
    const LatLng(13.1658268, 80.281365),
  ];

  /// Store markers here
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();

    // build markers once
    _markers = _zones.asMap().entries.map(
      (e) {
        return Marker(
          markerId: MarkerId("zone_${e.key}"),
          position: e.value,
          infoWindow: InfoWindow(title: "Zone ${e.key + 1}"),
        );
      },
    ).toSet();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laptop Service Zones"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              markers: _markers, // use stored markers
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Quick Service Page
                    },
                    child: const Text("Quick Service"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Booking Service Page
                    },
                    child: const Text("Booking Service"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
