import 'package:flutter/material.dart';
import 'package:servicemate_app/nearby_technicians/technician_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NearbyTechniciansPage extends StatelessWidget {
  final List<Technician> technicians;

  const NearbyTechniciansPage({
    super.key,
    required this.technicians,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Best Nearby Technicians"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: technicians.isEmpty
          ? const Center(child: Text("No technicians found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// PROFILE IMAGE
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(tech.image),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 14),

                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tech.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tech.role,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),

                            /// ADDRESS
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    tech.shopAddress,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            /// RATING (STATIC FOR NOW)
                            Row(
                              children: const [
                                Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "4.8 • Best Rated",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// CALL BUTTON
                      InkWell(
                        onTap: () =>
                            launchUrlString("tel:${tech.phone}"),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}