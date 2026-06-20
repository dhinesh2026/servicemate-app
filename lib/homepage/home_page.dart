import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:servicemate_app/all_services/service_model.dart';
import 'package:servicemate_app/api/allservice_api.dart';
import 'package:servicemate_app/api/categoriesAPI.dart';
import 'package:servicemate_app/api/review_service.dart';
import 'package:servicemate_app/api/technician_service.dart';
import 'package:servicemate_app/homepage/all_categories.dart';
import 'package:servicemate_app/homepage/membership_page.dart';
import 'package:servicemate_app/homepage/services_page.dart';
import 'package:servicemate_app/nearby_technicians/nearby_technicians_page.dart';
import 'package:servicemate_app/nearby_technicians/technician_model.dart';
import '../locationPage/user_current_location.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App color scheme
const Color appPrimaryColor = Color(0xFF2563EB);
const Color appSecondaryColor = Color(0xFF64748B);
const Color appBackgroundColor = Color(0xFFF8FAFC);
const Color appSurfaceColor = Color(0xFFFFFFFF);

/// ------------------ HOME CONTENT ------------------
class HomeContent extends StatefulWidget {
  final String? bookingId;

  const HomeContent({super.key, this.bookingId});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<FestivalTheme> _currentTheme = ValueNotifier(
    FestivalTheme.defaultTheme(),
  );

  // Mock data for festival banners
  final List<FestivalBanner> _festivalBanners = [
    FestivalBanner(
      id: '1',
      title: 'Diwali Special',
      imageUrl: 'assets/diyas-lam.png',
      theme: FestivalTheme.diwali(),
    ),
    FestivalBanner(
      id: '2',
      title: 'Christmas Offers',
      imageUrl: 'assets/christmas-tree.png',
      theme: FestivalTheme.christmas(),
    ),
    FestivalBanner(
      id: '3',
      title: 'Pongal Festival',
      imageUrl: 'assets/pongal-festival.png',
      theme: FestivalTheme.pongal(),
    ),
    FestivalBanner(
      id: '4',
      title: 'Eid Mubarak',
      imageUrl: 'assets/eid.png',
      theme: FestivalTheme.eid(),
    ),
  ];

  List<Map<String, String>> trustedPartners = [
    {
      "name": "Laptop Repair",
      "image": "assets/images/laptop.png",
      "category": "Laptop",
    },
    {
      "name": "CCTV Installation",
      "image": "assets/images/cctv.png",
      "category": "CCTV",
    },
    {
      "name": "Networking Setup",
      "image": "assets/images/networking.png",
      "category": "Networking",
    },
    {
      "name": "Server Installation",
      "image": "assets/images/server.png",
      "category": "Server",
    },
  ];

  List<Map<String, dynamic>> reviews = [];
  List<Technician> nearbyTechnicians = [];
  bool isLoadingTechnicians = true;
  String _selectedLocation = "Set Location";
  List<ServiceModel> allServices = [];

  bool get isPremiumUser => true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadSavedLocation();
    _fetchFestivalBanners();
    _loadNearbyTechnicians();
    loadServices();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocation =
          prefs.getString('selected_location') ?? "Set Location";
    });
  }

  Future<void> _saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_location', location);
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _loadReviews() async {
    try {
      final fetchedReviews = await fetchReviewsData();
      if (fetchedReviews.isNotEmpty) {
        print("📝 First review sample: ${fetchedReviews[0]}");
      }
      setState(() {
        reviews = fetchedReviews;
      });
    } catch (e) {
      print("❌ Error loading reviews: $e");
      setState(() {
        reviews = [
          {
            "userName": "Mani Kandan",
            "feedback": {
              "rating": 5,
              "comment":
                  "ServiceMate impressed me with their fast service and professional technicians. Highly recommended for all laptop repairs!",
            },
          },
          {
            "userName": "Priya Sharma",
            "feedback": {
              "rating": 4,
              "comment":
                  "Good service for CCTV installation. The technician was knowledgeable and completed the work on time.",
            },
          },
          {
            "userName": "Raj Kumar",
            "feedback": {
              "rating": 5,
              "comment":
                  "Excellent networking setup service. They solved all my connectivity issues efficiently.",
            },
          },
        ];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Using demo reviews data"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _fetchFestivalBanners() async {
    // TODO: Implement API call to fetch festival banners from MongoDB
  }

  Future<void> _loadNearbyTechnicians() async {
    try {
      final data = await TechnicianService.fetchNearbyTechnicians();
      setState(() {
        nearbyTechnicians = data;
        isLoadingTechnicians = false;
      });
    } catch (e) {
      debugPrint("❌ Technician load error: $e");
      setState(() {
        isLoadingTechnicians = false;
      });
    }
  }

  void loadServices() async {
    final data = await ServiceApi.fetchServices();
    setState(() {
      allServices = data;
    });
  }

  void _openAllServicesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ServicesPage(showVehicleServices: false),
      ),
    );
  }

  // ✅ Membership page navigate பண்ண helper method
  void _navigateToMembership() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MembershipPageUI(
          service:
              "General", // Banner / Premium section இருந்து வருவதால் generic
          problem: "General",
          price: 0,
        ),
      ),
    );
  }

  Future<void> _openBookingPage(String serviceName, String shopAddress) async {
    try {
      print("🔥 Fetching service: $serviceName");

      final serviceData = await fetchServiceData(serviceName);

      // 🔥 FIX: extract correct data
      final data = serviceData['data'] ?? serviceData;

      final List<Map<String, dynamic>> commonProblems =
          List<Map<String, dynamic>>.from(data['commonProblems'] ?? []);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceBookingDetailPage(
            serviceName: serviceName,
            shopAddress: data['shopAddress'] ?? shopAddress,
            bannerImage: data['bannerImage'] ?? "",
            basePrice: data['basePrice'] ?? 0,
            problems: commonProblems,
          ),
        ),
      );
    } catch (e) {
      print("❌ ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load service details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      color: appBackgroundColor,
      child: ValueListenableBuilder<FestivalTheme>(
        valueListenable: _currentTheme,
        builder: (context, theme, child) {
          return Column(
            children: [
              /// 🔝 FIXED TOP BAR
              Container(
                color: appSurfaceColor,
                padding: EdgeInsets.only(
                  top: topInset + 8,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset("assets/images/logo.png", height: 36),
                    ),
                    const Spacer(),
                    _buildLocationBar(theme),
                  ],
                ),
              ),

              /// 🟢 SCROLL AREA
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      _buildFestivalCarousel(theme),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildAllCategories(),
                      const SizedBox(height: 24),
                      _buildVehicleServicesUpcoming(context, allServices),
                      const SizedBox(height: 24),
                      _buildNearbyTechnicians(),
                      const SizedBox(height: 24),
                      if (isPremiumUser) _buildPremiumSection(theme),
                      const SizedBox(height: 24),
                      _buildTrustedPartners(),
                      const SizedBox(height: 24),
                      _buildCustomerReviews(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationBar(FestivalTheme theme) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const UserCurrentLocation()),
        );
        if (result != null && result.isNotEmpty) {
          await _saveLocation(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: appSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pin_drop, color: theme.primaryColor, size: 14),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _selectedLocation,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: theme.primaryColor, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyTechnicians() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nearby Technician's",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NearbyTechniciansPage(technicians: nearbyTechnicians),
                    ),
                  );
                },
                child: const Text(
                  "See more",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appPrimaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (isLoadingTechnicians)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (nearbyTechnicians.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "No nearby technicians found",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            )
          else
            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nearbyTechnicians.length,
                itemBuilder: (context, index) {
                  final tech = nearbyTechnicians[index];
                  return Container(
                    width: 165,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appSurfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(tech.image),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            InkWell(
                              onTap: () => launchUrlString("tel:${tech.phone}"),
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.call,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tech.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tech.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tech.shopAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ✅ CHANGE 1: Festival carousel banner-ல GestureDetector சேர்த்து membership navigate
  Widget _buildFestivalCarousel(FestivalTheme theme) {
    return CarouselSlider(
      items: _festivalBanners.map((banner) {
        return GestureDetector(
          onTap: _navigateToMembership, // ✅ Banner tap → Membership page
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(banner.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    banner.theme.primaryColor.withOpacity(0.85),
                    banner.theme.primaryColor.withOpacity(0.35),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Exclusive festival deals",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Text(
                            "Discover Offers",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: banner.theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: Icon(
                      banner.theme.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 170,
        autoPlay: true,
        viewportFraction: 0.92,
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        onPageChanged: (index, reason) {
          _currentTheme.value = _festivalBanners[index].theme;
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _openAllServicesPage,
        child: AbsorbPointer(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: appPrimaryColor),
                hintText: "Search for services...",
                border: InputBorder.none,
                filled: true,
                fillColor: appSurfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ CHANGE 2: Premium section-ஐ GestureDetector-ல wrap பண்ணி membership navigate
  Widget _buildPremiumSection(FestivalTheme theme) {
    return GestureDetector(
      onTap: _navigateToMembership, // ✅ Premium section tap → Membership page
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.9),
              theme.secondaryColor ?? theme.primaryColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "PREMIUM",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Exclusive Offers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Special discounts and priority services for our premium members",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
              ),
              child: Icon(Icons.arrow_forward, color: theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategories() {
    final services = allServices.take(8).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Our Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: _openAllServicesPage,
                child: const Text(
                  "See more",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: services.map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () =>
                          _openBookingPage(service.name, service.shopAddress),
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: appSurfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              service.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.miscellaneous_services,
                                  size: 32,
                                  color: Colors.grey,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedPartners() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Trusted Partners",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 110,
            child: InfiniteScrollRow(
              services: trustedPartners,
              onTap: (category) => _openBookingPage(category, category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Our Customers Love Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: reviews.isEmpty
                ? _buildEmptyReviews()
                : CarouselSlider(
                    items: reviews.map((review) {
                      final userName =
                          review['userName'] ?? review['name'] ?? 'Customer';
                      final userReview =
                          review['review'] ??
                          review['feedback']?['comment'] ??
                          'No review text available';
                      final rating = review['feedback']?['rating'] ?? 5;
                      return _buildReviewCard(userName, userReview, rating);
                    }).toList(),
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.85,
                      autoPlayInterval: const Duration(seconds: 5),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String userName, String reviewText, int rating) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appSurfaceColor,
        borderRadius: BorderRadius.circular(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: appPrimaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: appPrimaryColor),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < rating
                              ? Colors.orange
                              : Colors.grey.shade300,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              reviewText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.reviews,
            color: appPrimaryColor.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            "No reviews yet",
            style: TextStyle(
              fontSize: 16,
              color: appSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your experience!",
            style: TextStyle(
              fontSize: 12,
              color: appSecondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: appSurfaceColor,
        borderRadius: BorderRadius.circular(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              const url = "https://www.ideonixis.com/";
              try {
                await launchUrlString(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint("Could not launch $url: $e");
              }
            },
            child: const Text(
              "© Ideonixis Technologies",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Building smart digital solutions",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.black.withOpacity(0.08), thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                Icons.facebook,
                Colors.blue,
                "https://www.facebook.com/YourPage",
              ),
              const SizedBox(width: 14),
              _buildSocialIcon(
                Icons.camera_alt,
                Colors.pink,
                "https://www.instagram.com/YourProfile",
              ),
              const SizedBox(width: 14),
              _buildSocialIcon(
                Icons.ondemand_video,
                Colors.red,
                "https://www.youtube.com/@universalvibesDS",
              ),
              const SizedBox(width: 14),
              _buildSocialIcon(
                Icons.share,
                Colors.green,
                "https://play.google.com/store/apps/details?id=com.yourapp",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () async {
        try {
          await launchUrlString(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("Could not launch $url: $e");
        }
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(0.5),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

Widget _buildVehicleServicesUpcoming(
  BuildContext context,
  List<ServiceModel> services,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Vehicle Services",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ServicesPage(showVehicleServices: true),
                  ),
                );
              },
              child: const Text(
                "See more",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _vehicleRowWrapper(
                  _vehicleItem(
                    "Scooty",
                    Icons.electric_scooter,
                    upcoming: true,
                  ),
                ),
                _vehicleRowWrapper(
                  _vehicleItem("Bike", Icons.motorcycle, upcoming: true),
                ),
                _vehicleRowWrapper(
                  _vehicleItem(
                    "EV Scooty",
                    Icons.electric_bike,
                    upcoming: true,
                  ),
                ),
                _vehicleRowWrapper(
                  _vehicleItem("EV Station", Icons.ev_station, upcoming: true),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _vehicleRowWrapper(Widget child) {
  return Padding(
    padding: const EdgeInsets.only(right: 14),
    child: SizedBox(width: 90, child: child),
  );
}

Widget _vehicleItem(String title, IconData icon, {bool upcoming = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: appSurfaceColor,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 36, color: appPrimaryColor),
            if (upcoming)
              Positioned(
                top: -10,
                right: -26,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Upcoming",
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// ------------------ FESTIVAL THEME MODELS ------------------
class FestivalTheme {
  final Color primaryColor;
  final Color? secondaryColor;
  final IconData icon;
  final LinearGradient bannerGradient;

  FestivalTheme({
    required this.primaryColor,
    this.secondaryColor,
    required this.icon,
    required this.bannerGradient,
  });

  factory FestivalTheme.defaultTheme() {
    return FestivalTheme(
      primaryColor: appPrimaryColor,
      secondaryColor: appSecondaryColor,
      icon: Icons.celebration,
      bannerGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [appPrimaryColor, appPrimaryColor.withOpacity(0.7)],
      ),
    );
  }

  factory FestivalTheme.diwali() {
    return FestivalTheme(
      primaryColor: const Color(0xFFFFA726),
      secondaryColor: const Color(0xFFFFCA28),
      icon: Icons.celebration,
      bannerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFA726), Color(0xFFFFCA28)],
      ),
    );
  }

  factory FestivalTheme.christmas() {
    return FestivalTheme(
      primaryColor: const Color(0xFFDC2626),
      secondaryColor: const Color(0xFF16A34A),
      icon: Icons.ac_unit,
      bannerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDC2626), Color(0xFF16A34A)],
      ),
    );
  }

  factory FestivalTheme.pongal() {
    return FestivalTheme(
      primaryColor: const Color(0xFFEA580C),
      secondaryColor: const Color(0xFFF59E0B),
      icon: Icons.rice_bowl,
      bannerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
      ),
    );
  }

  factory FestivalTheme.eid() {
    return FestivalTheme(
      primaryColor: const Color(0xFF059669),
      secondaryColor: const Color(0xFF0D9488),
      icon: Icons.nightlight_round,
      bannerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF0D9488)],
      ),
    );
  }
}

class FestivalBanner {
  final String id;
  final String title;
  final String imageUrl;
  final FestivalTheme theme;

  FestivalBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.theme,
  });
}

/// ------------------ INFINITE SCROLL ROW ------------------
class InfiniteScrollRow extends StatefulWidget {
  final List<Map<String, String>> services;
  final Function(String) onTap;
  const InfiniteScrollRow({
    super.key,
    required this.services,
    required this.onTap,
  });

  @override
  State<InfiniteScrollRow> createState() => _InfiniteScrollRowState();
}

class _InfiniteScrollRowState extends State<InfiniteScrollRow> {
  final ScrollController _scrollController = ScrollController();
  late double _scrollSpeed;

  @override
  void initState() {
    super.initState();
    _scrollSpeed = 40;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double pixels = _scrollController.offset;

    Future.delayed(const Duration(milliseconds: 16), () {
      if (_scrollController.hasClients) {
        double newPixels = pixels + (_scrollSpeed * 0.016);
        if (newPixels >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(newPixels);
        }
        if (mounted) _startScrolling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = [...widget.services, ...widget.services];

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final service = displayList[index % widget.services.length];
        return GestureDetector(
          onTap: () => widget.onTap(service["name"]!),
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: appPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      service["image"]!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.build,
                          color: appPrimaryColor,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    service["name"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
