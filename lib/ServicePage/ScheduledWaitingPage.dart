// lib/ServicePage/ScheduledWaitingPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:servicemate_app/ServicePage/waiting_screen_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledWaitingPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ScheduledWaitingPage({super.key, required this.bookingData});

  @override
  State<ScheduledWaitingPage> createState() => _ScheduledWaitingPageState();
}

class _ScheduledWaitingPageState extends State<ScheduledWaitingPage> {
  DateTime? scheduleTime;
  Timer? _timer;
  String countdownText = "";
  bool _schedulingDone = false;
  bool _canOpenTracking = false;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _initNotifications();
    _parseScheduleTime();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToTracking();
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'service_reminder_channel',
      'Service Reminders',
      description:
          'Reminds clients when their scheduled service is about to start',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _scheduleNotification(DateTime scheduledTime) {
    if (_schedulingDone) return;

    final now = DateTime.now();
    final reminderTime = scheduledTime.subtract(const Duration(minutes: 15));

    // Reminder 15 minutes before
    if (reminderTime.isAfter(now)) {
      final reminderDelay = reminderTime.difference(now);
      Timer(reminderDelay, () {
        _showNotification(
          'Upcoming service',
          'Your service is in 15 minutes. Tap to open tracking.',
        );
      });
    }

    // Main notification at scheduled time
    if (scheduledTime.isAfter(now)) {
      final mainDelay = scheduledTime.difference(now);
      Timer(mainDelay, () {
        _showNotification(
          'Service starting now',
          'Your service is starting now. Tap to track engineer.',
        );
        if (mounted) {
          setState(() {
            _canOpenTracking = true;
          });
        }
      });
    } else {
      _canOpenTracking = true;
    }

    _schedulingDone = true;
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'service_reminder_channel',
      'Service Reminders',
      channelDescription: 'Reminds client when service is about to start',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _notifications.show(id, title, body, details);
  }

  void _parseScheduleTime() {
    final rawPrint = widget.bookingData['scheduledDateTime'];
    print("testtttttttttttttt: $rawPrint");

    try {
      String rawDate = widget.bookingData['scheduledDateTime']?.toString() ?? "";
      scheduleTime = _safeParseDate(rawDate);
      print("date and time:$scheduleTime");

      if (scheduleTime != null) {
        final now = DateTime.now();
        if (scheduleTime!.isBefore(now)) {
          setState(() {
            countdownText = "Starting now…";
            _canOpenTracking = true;
          });
        } else {
          _scheduleNotification(scheduleTime!);
          _startTimer();
        }
      } else {
        debugPrint("⚠️ Could not parse scheduledDateTime: $rawDate");
      }
    } catch (e) {
      debugPrint("❌ Error parsing schedule date: $e");
    }
  }

  DateTime? _safeParseDate(String rawDate) {
    rawDate = rawDate.trim();
    if (rawDate.isEmpty) return null;

    if ((rawDate.startsWith('"') && rawDate.endsWith('"')) ||
        (rawDate.startsWith("'") && rawDate.endsWith("'"))) {
      rawDate = rawDate.substring(1, rawDate.length - 1).trim();
    }

    try {
      if (rawDate.contains('T')) {
        final parsed = DateTime.parse(rawDate);
        return parsed.toLocal();
      }

      final cleaned = rawDate.split('GMT')[0].trim();

      try {
        final fmt = DateFormat("EEE MMM dd yyyy HH:mm:ss");
        return fmt.parse(cleaned);
      } catch (_) {
        try {
          final fmt2 = DateFormat("yyyy-MM-dd HH:mm:ss");
          return fmt2.parse(cleaned);
        } catch (e) {
          debugPrint("❌ Failed fallback parse formats for: $rawDate -> $e");
        }
      }

      return null;
    } catch (e) {
      debugPrint("❌ Failed to parse date: $rawDate -> $e");
      return null;
    }
  }

  void _startTimer() {
    if (scheduleTime == null) return;

    _updateCountdown();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = scheduleTime!.difference(DateTime.now());
      if (diff.isNegative || diff.inSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            countdownText = "Starting now…";
            _canOpenTracking = true;
          });
        }
      } else {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    if (scheduleTime == null) return;

    final diff = scheduleTime!.difference(DateTime.now());

    if (diff.isNegative || diff.inSeconds <= 0) {
      countdownText = "Starting now…";
      _canOpenTracking = true;
    } else {
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      if (days > 0) {
        countdownText = "Service starts in $days d ${hours}h ${minutes}m";
      } else if (hours > 0) {
        countdownText = "Service starts in ${hours}h ${minutes}m";
      } else if (minutes > 0) {
        countdownText = "Service starts in ${minutes}m ${seconds}s";
      } else {
        countdownText = "Service starts in ${seconds}s";
      }
    }

    if (mounted) setState(() {});
  }

  void _navigateToTracking() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingPage(
          bookingId: widget.bookingData['bookingId']?.toString() ?? "",
          engineerId: widget.bookingData['engineerId']?.toString() ?? "",
          engineerPhone: widget.bookingData['engineerPhone']?.toString() ?? "",
          engineerName: widget.bookingData['engineerName']?.toString() ?? "",
          engineerLat: (widget.bookingData['engineerLat'] is num)
              ? (widget.bookingData['engineerLat'] as num).toDouble()
              : double.tryParse(widget.bookingData['engineerLat']?.toString() ?? "0") ?? 0,
          engineerLng: (widget.bookingData['engineerLng'] is num)
              ? (widget.bookingData['engineerLng'] as num).toDouble()
              : double.tryParse(widget.bookingData['engineerLng']?.toString() ?? "0") ?? 0,
          serviceType: widget.bookingData['serviceType']?.toString() ?? "",
          problem: widget.bookingData['problem']?.toString() ?? "",
          model: widget.bookingData['model']?.toString() ?? "",
          address: widget.bookingData['address']?.toString() ?? "",
          lat: (widget.bookingData['lat'] is num)
              ? (widget.bookingData['lat'] as num).toDouble()
              : double.tryParse(widget.bookingData['lat']?.toString() ?? "0") ?? 0,
          lng: (widget.bookingData['lng'] is num)
              ? (widget.bookingData['lng'] as num).toDouble()
              : double.tryParse(widget.bookingData['lng']?.toString() ?? "0") ?? 0,
          otp: (widget.bookingData['otp'] is int)
              ? widget.bookingData['otp'] as int
              : int.tryParse(widget.bookingData['otp']?.toString() ?? "0") ?? 0,
          selfieImage: widget.bookingData['selfieImage']?.toString() ?? "",
        ),
      ),
    );
  }

  Future<void> _showWaitPopup() async {
    final displayDate = scheduleTime != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(scheduleTime!)
        : "Unknown time";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Please wait"),
        content: Text("Your service will start at $displayDate"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _callEngineer(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cannot make call")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildDetailTile(
    String title,
    String value, {
    IconData? icon,
    bool isPhone = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon ?? Icons.info, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : "-",
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        onTap: isPhone ? () => _callEngineer(value) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = scheduleTime != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(scheduleTime!)
        : "Invalid Date";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Confirmed"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.schedule,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your service is scheduled",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayDate,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (countdownText.isNotEmpty)
                            GestureDetector(
                              onTap:
                                  _canOpenTracking ? _navigateToTracking : null,
                              child: Chip(
                                backgroundColor: Colors.blue.withOpacity(0.08),
                                label: Text(
                                  countdownText,
                                  style: TextStyle(
                                    color: _canOpenTracking
                                        ? Colors.blue
                                        : Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                    decoration: _canOpenTracking
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailTile(
              "Booking ID",
              widget.bookingData['bookingId'] ?? "",
            ),
            _buildDetailTile(
              "Service Type",
              widget.bookingData['serviceType'] ?? "",
            ),
            _buildDetailTile("Problem", widget.bookingData['problem'] ?? ""),
            _buildDetailTile("Model", widget.bookingData['model'] ?? ""),
            _buildDetailTile(
              "Scheduled Time",
              displayDate,
              icon: Icons.access_time,
            ),
            _buildDetailTile(
              "Engineer",
              widget.bookingData['engineerName'] ?? "",
              icon: Icons.person,
            ),
            _buildDetailTile(
              "Engineer Phone",
              widget.bookingData['engineerPhone'] ?? "",
              icon: Icons.phone,
              isPhone: true,
            ),
            _buildDetailTile(
              "Address",
              widget.bookingData['address'] ?? "",
              icon: Icons.home,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _canOpenTracking ? _navigateToTracking : _showWaitPopup,
                    icon: const Icon(Icons.navigation),
                    label: const Text("Open Tracking"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Order cancelled")),
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancel Order"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 15),
            const Text(
              "Waiting for your scheduled service time...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "You will get a reminder 15 minutes before and a notification when the service starts.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
