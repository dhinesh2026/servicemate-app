import 'package:flutter/material.dart';
import 'package:servicemate_app/bookingpage/book_page.dart';

class ServiceBookingDetailPage extends StatefulWidget {
  final String serviceName;
  final String shopAddress;
  final String bannerImage;
  final int basePrice;
  final List<Map<String, dynamic>> problems;

  const ServiceBookingDetailPage({
    super.key,
    required this.serviceName,
    required this.shopAddress,
    required this.bannerImage,
    required this.basePrice,
    required this.problems,
  });

  @override
  State<ServiceBookingDetailPage> createState() =>
      _ServiceBookingDetailPageState();
}

class _ServiceBookingDetailPageState extends State<ServiceBookingDetailPage> {
  int selectedIndex = -1;
  bool isMember = false;
  final TextEditingController othersController = TextEditingController();

  bool get isOthersSelected =>
      selectedIndex != -1 &&
      widget.problems[selectedIndex]['problem'] == "Others";

  @override
  void dispose() {
    othersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.serviceName,
            style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 BANNER
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.asset(
                    widget.bannerImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "₹${widget.basePrice}+",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 TITLE
            const Text("Select Service",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            /// 🔥 MODERN CHIPS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(widget.problems.length, (index) {
                final problem = widget.problems[index];
                final selected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      if (!isOthersSelected) othersController.clear();
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Text(
                      problem['problem'],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),

            /// 🔥 OTHERS INPUT
            if (isOthersSelected) ...[
              const SizedBox(height: 14),
              TextField(
                controller: othersController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe your issue...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// 🔥 SUPER SAVES CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Super Saves",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Row(children: [Icon(Icons.build), SizedBox(width: 8), Text("Free Inspection")]),
                  SizedBox(height: 8),
                  Row(children: [Icon(Icons.cleaning_services), SizedBox(width: 8), Text("Cleaning")]),
                  SizedBox(height: 8),
                  Row(children: [Icon(Icons.flash_on), SizedBox(width: 8), Text("Same Day Service")]),
                  SizedBox(height: 8),
                  Row(children: [Icon(Icons.verified), SizedBox(width: 8), Text("7 Days Warranty")]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 MEMBERSHIP CARD (MODERN)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ServiceMate Plus",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),

                  const SizedBox(height: 10),

                  const Text("✔ 30 Days Warranty",
                      style: TextStyle(color: Colors.white)),
                  const Text("✔ 15% Discount",
                      style: TextStyle(color: Colors.white)),
                  const Text("✔ Priority Support",
                      style: TextStyle(color: Colors.white)),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() => isMember = true);
                      },
                      child: Text(isMember ? "Activated" : "Upgrade"),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      /// 🔥 MODERN BUTTON
      bottomNavigationBar: selectedIndex == -1
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  String problemText;

                  if (isOthersSelected) {
                    if (othersController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter your problem")),
                      );
                      return;
                    }
                    problemText = othersController.text.trim();
                  } else {
                    problemText =
                        widget.problems[selectedIndex]['problem'];
                  }

                  Map<String, dynamic> priceMap =
                      Map<String, dynamic>.from(
                          widget.problems[selectedIndex]['prices']);

                  if (isMember) {
                    priceMap.updateAll((key, value) {
                      return (value * 0.85).toInt();
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailPage(
                        serviceName: widget.serviceName,
                        selectedProblem: problemText,
                        selectedPrice: priceMap,
                      ),
                    ),
                  );
                },
                child: Text(
                  isMember
                      ? "Continue (Discount Applied)"
                      : "Continue",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}