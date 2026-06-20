import 'package:flutter/material.dart';
import 'package:servicemate_app/all_services/service_model.dart';
import 'package:servicemate_app/api/allservice_api.dart';
import 'package:servicemate_app/api/categoriesAPI.dart';
import 'package:servicemate_app/homepage/all_categories.dart';

class ServicesPage extends StatefulWidget {
  final bool showVehicleServices;

  const ServicesPage({super.key, this.showVehicleServices = false});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late bool isHomeAppliance;

  /// 🔥 API services (Home Appliances)
  List<ServiceModel> apiServices = [];
  bool isLoading = true;

  /// 🚧 Vehicle Services (UPCOMING – static)
  final List<Map<String, dynamic>> vehicleServices = [
    {
      "title": "Bike Service",
      "price": 499,
      "image": "assets/images/bike.png",
      "upcoming": true,
    },
    {
      "title": "Car Service",
      "price": 999,
      "image": "assets/images/car.png",
      "upcoming": true,
    },
    {
      "title": "Battery Check",
      "price": 199,
      "image": "assets/images/battery.png",
      "upcoming": true,
    },
    {
      "title": "Tyre Replacement",
      "price": 299,
      "image": "assets/images/tyre.png",
      "upcoming": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    isHomeAppliance = !widget.showVehicleServices;
    _loadServices();
  }

  /// 🔥 LOAD ALL SERVICES FROM API
  Future<void> _loadServices() async {
    try {
      final List<ServiceModel> services = await ServiceApi.fetchServices();

      if (!mounted) return;

      setState(() {
        apiServices = services.where((s) => s.category != "Vehicle").toList();
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint("❌ Failed to load services: $e");
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// 🔥 SAME FLOW AS HOME PAGE
  Future<void> _openBookingPage(String serviceName, String shopAddress) async {
    try {
      final serviceData = await fetchServiceData(serviceName);

      final List<Map<String, dynamic>> commonProblems =
          List<Map<String, dynamic>>.from(serviceData['commonProblems'] ?? []);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceBookingDetailPage(
            serviceName: serviceName,
            shopAddress: serviceData['shopAddress'] ?? "",
            bannerImage: serviceData['bannerImage'],
            basePrice: serviceData['basePrice'],
            problems: commonProblems,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load service details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = isHomeAppliance ? apiServices : vehicleServices;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 18),
                  ),
                  const Spacer(),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Our Services",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose from a wide range of trusted repair\nand maintenance solutions.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// 🔘 Toggle Buttons
              Row(
                children: [
                  _categoryButton(
                    title: "Home Appliances",
                    isActive: isHomeAppliance,
                    onTap: () => setState(() => isHomeAppliance = true),
                  ),
                  const SizedBox(width: 12),
                  _categoryButton(
                    title: "Vehicle Services",
                    isActive: !isHomeAppliance,
                    onTap: () => setState(() => isHomeAppliance = false),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🧩 Grid
              Expanded(
                child: isHomeAppliance && isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: currentList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          return _serviceCard(apiServices[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🟦 Category Button
  Widget _categoryButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 🧊 Service Card
  Widget _serviceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () {
        _openBookingPage(service.name, service.shopAddress);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Tap to view details",
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                service.image,
                height: 70,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.miscellaneous_services),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
