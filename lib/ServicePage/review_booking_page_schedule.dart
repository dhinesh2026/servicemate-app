import 'dart:io';
import 'package:flutter/material.dart';
import '../ServicePage/waiting_screen_page.dart';
import '../api/signupAPI.dart';

class ReviewScheduleBookingPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final File? problemImage;

  const ReviewScheduleBookingPage({
    super.key,
    required this.bookingData,
    required this.problemImage,
  });

  // 👉 Call API and send image + data
  Future<void> _processBooking(BuildContext context) async {
    print("hollo bro: $bookingData");
    try {
      final result = await SignupAPI.bookScheduleService(
        bookingData: bookingData,
        imageFile: problemImage,
      );

      if (result["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingForEngineerPage(
              bookingId: result["bookingId"] ?? "UNKNOWN",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Booking failed: ${result["message"] ?? "Try again!"}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPartnership = bookingData["bookingMode"] == "Partnership";

    // 🔹 Parse scheduledDateTime (if available)
    DateTime? scheduledDateTime;
    if (bookingData["scheduledDateTime"] != null) {
      scheduledDateTime = DateTime.tryParse(bookingData["scheduledDateTime"]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Review Booking")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(bookingData["userName"] ?? ""),
              subtitle: Text("Phone: ${bookingData["phone"] ?? ""}"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),

            // Booking Summary
            _buildDataRow("Service", bookingData["serviceType"] ?? ""),
            _buildDataRow("Model", bookingData["model"] ?? ""),
            _buildDataRow("Problem", bookingData["problem"] ?? ""),
            _buildDataRow("Laptop Count", bookingData["laptopCount"] ?? ""),
            _buildDataRow("Address", bookingData["address"] ?? ""),

            // 🔹 Show Scheduled Date & Time if available
            if (scheduledDateTime != null) ...[
              _buildDataRow(
                "Scheduled Date",
                "${scheduledDateTime.day}/${scheduledDateTime.month}/${scheduledDateTime.year}",
              ),
              _buildDataRow(
                "Scheduled Time",
                TimeOfDay.fromDateTime(scheduledDateTime).format(context),
              ),
            ],

            if (bookingData["bookingMode"] != null)
              _buildDataRow("Booking Mode", bookingData["bookingMode"]),
            if (isPartnership) ...[
              _buildDataRow("Company Name", bookingData["companyName"] ?? ""),
              _buildDataRow("Company ID", bookingData["companyId"] ?? ""),
              _buildDataRow("Company Phone", bookingData["companyPhone"] ?? ""),
            ] else if (bookingData["selfOption"] != null)
              _buildDataRow("Option", bookingData["selfOption"] ?? ""),

            // Problem Image
            if (problemImage != null) ...[
              const SizedBox(height: 12),
              Image.file(
                problemImage!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              "• No charges will apply until your task is finished.\n"
              "• You can cancel your booking free of charge up to 7 days before the scheduled service.\n"
              "• Cancellations made within 7 days of the service date may be subject to a fee.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _processBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
