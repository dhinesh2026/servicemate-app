import 'package:flutter/material.dart';
import '../ServicePage/fast_service_form.dart';
import '../ServicePage/schedule_service_form.dart';

class ServiceOptionsPage extends StatelessWidget {
  final String service; // 🔹 Service name received from PaymentPage
  final String problem; // 🔹 Service name received from PaymentPage
  final dynamic price;
  final dynamic title;

  const ServiceOptionsPage({
    super.key, 
    required this.service,
    required this.problem,
    required this.price,
    required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "$service Options",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "How would you like to proceed?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // 🚀 Fast Service Card
            _ServiceOptionCard(
              title: "Fast Service",
              description:
                  "Get your $service request handled immediately with our fast-track option.",
              color: Colors.green,
              icon: Icons.flash_on_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastServicePage(
                      serviceKey: "FAST_SERVICE_MEMBERSHIP",
                      service: service, // 👈 send name here
                      problem: problem,
                      price: price,
                      title: title,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 📅 Schedule Service Card
            _ServiceOptionCard(
              title: "Schedule Service",
              description:
                  "Plan your $service for a date and time that suits you best.",
              color: Colors.blue,
              icon: Icons.calendar_month_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleServicePage(
                      serviceKey: "SCHEDULE_SERVICE_MEMBERSHIP",
                      service: service, // 👈 send name here
                      problem: problem,
                      price: price,
                      title: title,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Card Widget with subtle animation
class _ServiceOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceOptionCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
