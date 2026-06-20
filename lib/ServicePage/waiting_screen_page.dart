// lib/screens/tracking_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'work_progress_page.dart';

class TrackingPage extends StatefulWidget {
  final String bookingId;
  final String engineerId;
  final String engineerPhone;
  final String engineerName;
  final double engineerLat;
  final double engineerLng;
  final String serviceType;
  final String problem;
  final String model;
  final String address;
  final double lat; // customer lat
  final double lng; // customer lng
  final int otp; // booking otp
  final String selfieImage; // engineer selfie

  const TrackingPage({
    super.key,
    required this.bookingId,
    required this.engineerId,
    required this.engineerPhone,
    required this.engineerName,
    required this.engineerLat,
    required this.engineerLng,
    required this.serviceType,
    required this.problem,
    required this.model,
    required this.address,
    required this.lat,
    required this.lng,
    required this.otp,
    required this.selfieImage,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng _customerLocation;
  late LatLng _engineerLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _readableAddress = "";
  StreamSubscription<DocumentSnapshot>? _locationSubscription;
  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  bool _mapInitialized = false;
  bool _isLoading = true;
  String _currentStatus = 'accepted';

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _listenForStatusUpdates();
    _setupFCMHandlers();
  }

  void _setupFCMHandlers() {
    // Optional: if you want to handle FCM messages while on this screen
    FirebaseMessaging.onMessage.listen((msg) {
      // handle if needed
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      // handle if needed
    });
  }

  /// Initialize map and listeners
  Future<void> _initializeMap() async {
    try {
      _customerLocation = LatLng(widget.lat, widget.lng);
      _engineerLocation = LatLng(widget.engineerLat, widget.engineerLng);

      await _fetchReadableAddress();
      await _addMarkers();

      _listenEngineerLocation();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Map initialization error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _listenForStatusUpdates() {
    _statusSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final status = (data['status'] ?? 'accepted').toString();

        debugPrint("📱 Status changed: $status");

        setState(() {
          _currentStatus = status;
        });

        if (status == 'engineer_reached') {
          print("engineer_reachedengineer_reachedengineer_reachedengineer_reachedengineer_reached");
          _navigateToWorkProgressPage(data);
        } else if (status == 'cancelled') {
          _showCancelledDialog();
        }
      }
    }, onError: (e) {
      debugPrint("❌ Status listener error: $e");
    });
  }

  void _navigateToWorkProgressPage(Map<String, dynamic> data) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkProgressPage(
          bookingId: widget.bookingId,
          engineerName: widget.engineerName,
          engineerPhone: widget.engineerPhone,
          serviceType: widget.serviceType,
          problem: widget.problem,
          model: widget.model,
          selfieImage: widget.selfieImage,
        ),
      ),
    );
  }

  void _showCancelledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Text("Booking Cancelled"),
          ],
        ),
        content: const Text("The engineer has cancelled this booking."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchReadableAddress() async {
    try {
      final list = await placemarkFromCoordinates(widget.lat, widget.lng);
      if (list.isNotEmpty) {
        final p = list.first;
        _readableAddress = "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.postalCode ?? ''}";
        if (mounted) setState(() {});
      } else {
        _readableAddress = widget.address;
      }
    } catch (e) {
      debugPrint("❌ Geocoding error: $e");
      _readableAddress = widget.address;
    }
  }

  Future<BitmapDescriptor> _getEngineerIcon() async {
    try {
      final image = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/map_service_icon.png',
      );
      return image;
    } catch (e) {
      debugPrint("❌ Custom icon load failed: $e");
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  Future<void> _addMarkers() async {
    try {
      final engineerIcon = await _getEngineerIcon();

      final customerMarker = Marker(
        markerId: const MarkerId("customer"),
        position: _customerLocation,
        infoWindow: const InfoWindow(title: "📍 Client Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      final engineerMarker = Marker(
        markerId: const MarkerId("engineer"),
        position: _engineerLocation,
        infoWindow: InfoWindow(title: "🛠 ${widget.engineerName}"),
        icon: engineerIcon,
        anchor: const Offset(0.5, 1.0),
      );

      setState(() {
        _markers
          ..clear()
          ..add(customerMarker)
          ..add(engineerMarker);
      });
    } catch (e) {
      debugPrint("❌ Marker error: $e");
    }
  }

  /// Directions API: replace the API key below with your own and secure it properly
  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    try {
      const apiKey = "AIzaSyBCV-SK7daO9mRpUXULRFtuU3k4z26ovTA"; // <-- replace
      final url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        debugPrint("❌ Directions API error: ${res.statusCode}");
        return [];
      }
      final data = jsonDecode(res.body);
      if (data['status'] != 'OK') {
        debugPrint("❌ Directions API status: ${data['status']}");
        return [];
      }
      if ((data['routes'] as List).isEmpty) return [];
      final points = data['routes'][0]['overview_polyline']['points'] as String;
      return _decodePolyline(points);
    } catch (e) {
      debugPrint("❌ Route points error: $e");
      return [];
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final poly = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      final point = LatLng(lat / 1e5, lng / 1e5);
      poly.add(point);
    }
    return poly;
  }

  Future<void> _addPolyline() async {
    try {
      if (!mounted) return;
      final points = await _getRoutePoints(_engineerLocation, _customerLocation);
      if (points.isEmpty) {
        debugPrint("⚠️ No route points found");
        return;
      }
      setState(() {
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 4,
            points: points,
          ));
      });
    } catch (e) {
      debugPrint("❌ Polyline error: $e");
    }
  }

  void _listenEngineerLocation() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId);

      // Create doc if not exists (initial data)
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({
          'engineerLat': widget.engineerLat,
          'engineerLng': widget.engineerLng,
          'engineerId': widget.engineerId,
          'engineerName': widget.engineerName,
          'engineerPhone': widget.engineerPhone,
          'serviceType': widget.serviceType,
          'problem': widget.problem,
          'model': widget.model,
          'address': widget.address,
          'lat': widget.lat,
          'lng': widget.lng,
          'otp': widget.otp,
          'selfieImage': widget.selfieImage,
          'helpRequested': false,
          'status': 'accepted',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _locationSubscription = docRef.snapshots().listen((snap) async {
        if (!snap.exists || !mounted) return;
        final data = snap.data();
        if (data == null) return;

        final engLat = (data['engineerLat'] as num?)?.toDouble();
        final engLng = (data['engineerLng'] as num?)?.toDouble();
        if (engLat == null || engLng == null) return;

        final newLoc = LatLng(engLat, engLng);
        setState(() {
          _engineerLocation = newLoc;
        });

        await _addMarkers();
        await _addPolyline();

        if (_mapController.isCompleted && _mapInitialized) {
          final controller = await _mapController.future;

          final south = LatLng(
            _engineerLocation.latitude < _customerLocation.latitude ? _engineerLocation.latitude : _customerLocation.latitude,
            _engineerLocation.longitude < _customerLocation.longitude ? _engineerLocation.longitude : _customerLocation.longitude,
          );
          final north = LatLng(
            _engineerLocation.latitude > _customerLocation.latitude ? _engineerLocation.latitude : _customerLocation.latitude,
            _engineerLocation.longitude > _customerLocation.longitude ? _engineerLocation.longitude : _customerLocation.longitude,
          );
          final bounds = LatLngBounds(southwest: south, northeast: north);

          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            } catch (e) {
              // Sometimes animateCamera with bounds can throw if map not ready — ignore
            }
          });
        }
      }, onError: (e) {
        debugPrint("❌ Firestore error: $e");
      });
    } catch (e) {
      debugPrint("❌ Firestore setup error: $e");
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot place call")));
      }
    } catch (e) {
      debugPrint("❌ Phone call error: $e");
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingScreen() : Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _customerLocation, zoom: 14),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) async {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
            _mapInitialized = true;

            // add polyline after a small delay to ensure map ready
            Future.delayed(const Duration(milliseconds: 1000), () {
              _addPolyline();
            });
          },
        ),
        _buildLegend(),
        _buildBackButton(context),
        _buildBottomInfoCard(),
        _buildStatusIndicator(),
      ]),
    );
  }

  Widget _buildLoadingScreen() => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Loading Map...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _buildLegend() => Positioned(
        top: 80,
        left: 12,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.location_on, color: Colors.red, size: 18), SizedBox(width: 6), Text("Client Location")]),
            Row(children: [Icon(Icons.engineering, color: Colors.blue, size: 18), SizedBox(width: 6), Text("Engineer Location")]),
          ]),
        ),
      );

  Widget _buildBackButton(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      );

  Widget _buildStatusIndicator() => Positioned(
        top: 150,
        left: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _getStatusColor(), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
          child: Row(children: [
            Icon(_getStatusIcon(), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(_getStatusText(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
      );

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'engineer_reached':
        return Colors.orange;
      case 'work_completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case 'engineer_reached':
        return Icons.timer;
      case 'work_completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.engineering;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case 'engineer_reached':
        return "Engineer Reached - Work Starting Soon";
      case 'work_completed':
        return "Work Completed - Ready for Payment";
      case 'cancelled':
        return "Booking Cancelled";
      default:
        return "Engineer is on the way to your location";
    }
  }

  Widget _buildBottomInfoCard() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListTile(
              leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(widget.selfieImage)),
              title: Text(widget.engineerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Phone: ${widget.engineerPhone}"),
              trailing: IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () => _makePhoneCall(widget.engineerPhone)),
            ),
            const Divider(),
            Text("Booking #${widget.bookingId}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Service: ${widget.serviceType}"),
            Text("Problem: ${widget.problem}"),
            Text("Model: ${widget.model}"),
            Text("Address: ${_readableAddress.isNotEmpty ? _readableAddress : widget.address}"),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(14)),
                child: Text("OTP: ${widget.otp}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({'helpRequested': true});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Help request sent!")));
                },
                icon: const Icon(Icons.support_agent),
                label: const Text("Help"),
              ),
            ]),
          ]),
        ),
      );
}

/// 🔹 Waiting Page (Unchanged - working fine)
class WaitingForEngineerPage extends StatefulWidget {
  final String bookingId;
  const WaitingForEngineerPage({super.key, required this.bookingId});

  @override
  State<WaitingForEngineerPage> createState() => _WaitingForEngineerPageState();
}

class _WaitingForEngineerPageState extends State<WaitingForEngineerPage> {
  bool engineerAccepted = false;

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() {
    FirebaseMessaging.onMessage.listen(_handleFCM);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCM);
  }

  void _handleFCM(RemoteMessage msg) {
    final data = msg.data;
    if (data['bookingId'] == widget.bookingId &&
        data['status'] == 'accepted' &&
        !engineerAccepted) {
      engineerAccepted = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingPage(
            bookingId: data['bookingId'] ?? "",
            engineerId: data['engineerId'] ?? "",
            engineerPhone: data['engineerPhone'] ?? "",
            engineerName: data['engineerName'] ?? "",
            engineerLat:
                double.tryParse(data['engineerLat']?.toString() ?? "0") ?? 0,
            engineerLng:
                double.tryParse(data['engineerLng']?.toString() ?? "0") ?? 0,
            serviceType: data['serviceType'] ?? "",
            problem: data['problem'] ?? "",
            model: data['model'] ?? "",
            address: data['address'] ?? "",
            lat: double.tryParse(data['lat']?.toString() ?? "0") ?? 0,
            lng: double.tryParse(data['lng']?.toString() ?? "0") ?? 0,
            otp: int.tryParse(data['otp']?.toString() ?? "0") ?? 0,
            selfieImage: data['selfieImage']?.toString() ?? "",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Image.asset("assets/searching.gif", height: 220),
            const SizedBox(height: 30),
            const Text(
              "Looking for nearby engineers...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel Booking",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: Colors.orange,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Booking ID: ${widget.bookingId}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.timer, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}