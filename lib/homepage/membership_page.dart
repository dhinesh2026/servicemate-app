import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/BaseWidget.dart';
import '../Payment/payment_page.dart';

class MembershipPageUI extends StatefulWidget {
  final String service; // ✅ New field for service name
  final String problem; // ✅ New field for service name
  final dynamic price;
  const MembershipPageUI({
    super.key, 
    required this.service,
    required this.problem,
    required this.price});

  @override
  State<MembershipPageUI> createState() => _MembershipPageUIState();
}

class _MembershipPageUIState extends State<MembershipPageUI> {
  late Future<List<Map<String, dynamic>>> _membershipsFuture;

  @override
  void initState() {
    super.initState();
    _membershipsFuture = fetchMemberships();
  }

  // 🔹 Fetch membership data from Node.js + MongoDB
  Future<List<Map<String, dynamic>>> fetchMemberships() async {
    final response = await http.get(
      Uri.parse('https://servicemate.ideonixis.com/memberships'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'] ?? '',
          'title': item['title'] ?? '',
          'price': item['price'] ?? 0,
          'originalPrice': item['originalPrice'] ?? 0,
          'discount': item['discount'] ?? '',
          'image': item['image'] ?? '',
          'color': item['color'] ?? '#FDD700',
          'duration': item['duration'] ?? '',
          'serviceDiscount': item['serviceDiscount'] ?? 0,
        };
      }).toList();
    } else {
      throw Exception('Failed to load memberships');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Membership Plans',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _membershipsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No memberships available'));
            }

            final memberships = snapshot.data!;

            return Column(
              children: [
                // ✅ Display selected service name at top
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_repair_service,
                          color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        "Service: ${widget.service}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 Membership list carousel
                Expanded(
                  child: PageView.builder(
                    itemCount: memberships.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      final m = memberships[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 24),
                        child: MembershipCard(
                          title: m['title'],
                          imageUrl: m['image'],
                          price: m['price'],
                          originalPrice: m['originalPrice'],
                          discount: m['discount'],
                          duration: m['duration'],
                          colorHex: m['color'],
                          service: widget.service, // ✅ pass service name
                          problem: widget.problem, // ✅ pass service name
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MembershipCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int price;
  final int originalPrice;
  final String discount;
  final String duration;
  final String colorHex;
  final String service; // ✅ added
  final String problem; // ✅ added

  const MembershipCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.duration,
    required this.colorHex,
    required this.service,
    required this.problem,
  });

  Color _hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Membership Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          ),

          // 🔹 Membership Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _hexToColor(colorHex),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹$originalPrice',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      discount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: $duration',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 Buy Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            title: title,
                            price: price,
                            problem: problem,
                            service: service, // ✅ Pass to payment
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hexToColor(colorHex),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text(
                      "Buy Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
