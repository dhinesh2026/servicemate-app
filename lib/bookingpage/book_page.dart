import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:servicemate_app/ServicePage/fast_service_form.dart';
import 'package:servicemate_app/ServicePage/schedule_service_form.dart';
import '../homepage/membership_page.dart';

class ServiceDetailPage extends StatefulWidget {
  final String serviceName;
  final String selectedProblem;
  final Map<String, dynamic>? selectedPrice;

  const ServiceDetailPage({
    super.key,
    required this.serviceName,
    required this.selectedProblem,
    this.selectedPrice,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  int selectedCardIndex = -1;
  late List<Map<String, String>> serviceOptions;
  GoogleMapController? mapController;

  final LatLng _defaultCenter = const LatLng(13.0827, 80.2707); // Chennai
  Set<Marker> _engineerMarkers = {};
  bool _loadingEngineers = true;

  @override
  void initState() {
    super.initState();

    serviceOptions = [
      {
        "title": "Fast Service",
        "icon": "assets/fastservice_icon.png",
        "description": "Quick fix within 1 hour",
        "price": widget.selectedPrice != null
            ? "₹${widget.selectedPrice!['fastService']}"
            : "₹150",
      },
      {
        "title": "Schedule Service",
        "icon": "assets/schedule_icon.png",
        "description": "Book your preferred time",
        "price": widget.selectedPrice != null
            ? "₹${widget.selectedPrice!['scheduledService']}"
            : "₹120",
      },
      {
        "title": "Premium Service",
        "icon": "assets/premium_icon.png",
        "description": "Warranty + Membership perks",
        "price": widget.selectedPrice != null
            ? "₹${widget.selectedPrice!['membership']}"
            : "₹499",
      },
    ];

    // Fetch engineers only once on page load
    _loadEngineers();
  }

  Future<void> _loadEngineers() async {
    setState(() {
      _loadingEngineers = true;
    });

    try {
      final url = Uri.parse("https://servicemate.ideonixis.com/engineers/onduty");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);

        if (jsonResponse['success'] == true) {
          List data = jsonResponse['data'];

          Set<Marker> markers = {};
          for (var eng in data) {
            if (eng['location'] != null &&
                eng['location']['latitude'] != null &&
                eng['location']['longitude'] != null) {
              double lat = double.tryParse(eng['location']['latitude'].toString()) ?? 0;
              double lng = double.tryParse(eng['location']['longitude'].toString()) ?? 0;

              markers.add(
                Marker(
                  markerId: MarkerId(eng['_id'].toString()),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                    title: eng['name'] ?? "Engineer",
                    snippet: eng['status'] ?? "On Duty",
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              );
            }
          }

          setState(() {
            _engineerMarkers = markers;
            _loadingEngineers = false;
          });
        } else {
          debugPrint("Server returned success=false: ${res.body}");
          setState(() {
            _loadingEngineers = false;
          });
        }
      } else {
        debugPrint("Server error: ${res.body}");
        setState(() {
          _loadingEngineers = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching engineers: $e");
      setState(() {
        _loadingEngineers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          "${widget.serviceName} - ${widget.selectedProblem}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: screenHeight * 0.40,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _loadingEngineers
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      onMapCreated: (controller) => mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _defaultCenter,
                        zoom: 13,
                      ),
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      markers: _engineerMarkers,
                    ),
            ),
          ),
          // Service Options Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    "Available Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: serviceOptions.length,
                    itemBuilder: (context, index) {
                      final option = serviceOptions[index];
                      bool isSelected = selectedCardIndex == index;
                      String buttonText = option["title"]!.contains("Premium")
                          ? "View Plan"
                          : "Book Now";

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          elevation: isSelected ? 6 : 2,
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: isSelected
                                ? const BorderSide(
                                    color: Colors.blueAccent, width: 1.2)
                                : BorderSide.none,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                selectedCardIndex = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    option["icon"]!,
                                    width: 32,
                                    height: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option["title"]!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.blueAccent
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option["description"]!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        option["price"]!,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.blueAccent
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (option["title"]!
                                              .contains("Fast")) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FastServicePage(
                                                  service: widget.serviceName,
                                                  problem:
                                                      widget.selectedProblem,
                                                  price: widget.selectedPrice?[
                                                      'fastService'],
                                                  serviceKey: "FAST_SERVICE",
                                                  title: "",
                                                ),
                                              ),
                                            );
                                          } else if (option["title"]!
                                              .contains("Schedule")) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ScheduleServicePage(
                                                  service: widget.serviceName,
                                                  problem:
                                                      widget.selectedProblem,
                                                  price: widget.selectedPrice?[
                                                      'scheduledService'],
                                                  serviceKey: "FAST_SCHEDULED_SERVICE",
                                                  title: "",
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MembershipPageUI(
                                                      service: widget.serviceName,
                                                      problem:widget.selectedProblem,
                                                      price: widget.selectedPrice?[
                                                      'MembershipService'],
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          buttonText,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
