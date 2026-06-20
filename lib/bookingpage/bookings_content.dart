import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// App color scheme
const Color appPrimaryColor = Color(0xFF2563EB);
const Color appSecondaryColor = Color(0xFF64748B);
const Color appBackgroundColor = Color(0xFFF8FAFC);
const Color appSurfaceColor = Color(0xFFFFFFFF);

class BookingsContent extends StatefulWidget {
  const BookingsContent({super.key});

  @override
  State<BookingsContent> createState() => _BookingsContentState();
}

class _BookingsContentState extends State<BookingsContent> {
  late Future<List<dynamic>> _bookingsFuture;
  String? _userId;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // FIX: Initialize _bookingsFuture immediately
    _bookingsFuture = Future.value([]);
    _loadUserIdAndFetchBookings();
  }

  Future<void> _loadUserIdAndFetchBookings() async {
    await _loadUserId();
    if (_userId != null) {
      setState(() {
        _bookingsFuture = fetchBookings();
      });
    }
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      setState(() {
        _userId = storedUserId;
      });
    } catch (e) {
      print('❌ Error loading userId: $e');
    }
  }

  Future<List<dynamic>> fetchBookings() async {
    try {
      if (_userId == null || _userId!.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse('https://servicemate.ideonixis.com/bookings/$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load bookings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  List<dynamic> _filterBookings(List<dynamic> bookings) {
    switch (_selectedFilter) {
      case 'Fast Service':
        return bookings.where((booking) => 
          booking['serviceType']?.toString().toLowerCase().contains('fast') == true ||
          booking['serviceSpeed']?.toString().toLowerCase().contains('fast') == true
        ).toList();
      case 'Schedule Service':
        return bookings.where((booking) => 
          booking['serviceType']?.toString().toLowerCase().contains('schedule') == true ||
          booking['serviceSpeed']?.toString().toLowerCase().contains('schedule') == true
        ).toList();
      case 'All':
      default:
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: appSurfaceColor,
        foregroundColor: appPrimaryColor,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: appSurfaceColor,
        // BACK ICON ADDED HERE
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Bookings List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (_userId == null) {
                  return _buildLoadingState('Loading user information...');
                }

                if (_userId != null && _userId!.isEmpty) {
                  return _buildErrorState(
                    icon: Icons.person_off,
                    title: 'User not found',
                    subtitle: 'Please login again'
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState('Loading your bookings...');
                }
                
                if (snapshot.hasError) {
                  return _buildErrorState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong!',
                    subtitle: snapshot.error.toString(),
                    showRetry: true,
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final allBookings = snapshot.data!;
                final filteredBookings = _filterBookings(allBookings);
                
                if (filteredBookings.isEmpty) {
                  return _buildNoFilterResults();
                }

                return _buildBookingsList(filteredBookings);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter Section
  Widget _buildFilterSection() {
    return Container(
      color: appSurfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildFilterButton('All', Icons.all_inclusive)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterButton('Fast', Icons.flash_on)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterButton('Schedule', Icons.schedule)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, IconData icon) {
    final isSelected = _selectedFilter == filter || 
                      (filter == 'Fast' && _selectedFilter == 'Fast Service') ||
                      (filter == 'Schedule' && _selectedFilter == 'Schedule Service');
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (filter == 'Fast') {
            _selectedFilter = 'Fast Service';
          } else if (filter == 'Schedule') {
            _selectedFilter = 'Schedule Service';
          } else {
            _selectedFilter = filter;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? appPrimaryColor : appSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? appPrimaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: appPrimaryColor.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? appSurfaceColor : appSecondaryColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? appSurfaceColor : appSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: appSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appSecondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                subtitle.length > 100 ? '${subtitle.substring(0, 100)}...' : subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appSecondaryColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserIdAndFetchBookings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  foregroundColor: appSurfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 70,
              color: appSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: TextStyle(
                color: appSecondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here',
              style: TextStyle(
                color: appSecondaryColor.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // No Filter Results
  Widget _buildNoFilterResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 'Fast Service' 
                ? Icons.flash_off 
                : _selectedFilter == 'Schedule Service'
                  ? Icons.schedule_outlined
                  : Icons.search_off,
              size: 70,
              color: appSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No $_selectedFilter\nBookings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appSecondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                });
              },
              child: Text(
                'Show All Bookings',
                style: TextStyle(
                  color: appPrimaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bookings List
  Widget _buildBookingsList(List<dynamic> bookings) {
    final upcoming = bookings
        .where((b) => b['status'] != 'Completed' && b['status'] != 'Cancelled')
        .toList();
    final past = bookings
        .where((b) => b['status'] == 'Completed' || b['status'] == 'Cancelled')
        .toList();

    return RefreshIndicator(
      backgroundColor: appSurfaceColor,
      color: appPrimaryColor,
      onRefresh: () async {
        setState(() {
          _bookingsFuture = fetchBookings();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (upcoming.isNotEmpty) ...[
            _buildSectionHeader('Upcoming Services'),
            const SizedBox(height: 12),
            ...upcoming.map((b) => _buildBookingCard(b)).toList(),
            const SizedBox(height: 20),
          ],
          
          if (past.isNotEmpty) ...[
            _buildSectionHeader('Past Services'),
            const SizedBox(height: 12),
            ...past.map((b) => _buildBookingCard(b, isPast: true)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: appPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map booking, {bool isPast = false}) {
    final status = booking['status'] ?? 'Pending';
    final service = booking['serviceType'] ?? booking['serviceSpeed'] ?? 'Unknown Service';
    final scheduledDateTime = booking['scheduledDateTime'] ?? '';
    final date = _formatDate(scheduledDateTime);
    final time = _formatTime(scheduledDateTime);
    final price = _extractPriceFromProblem(booking['problem'] ?? '');
    final engineerName = booking['engineerName'] ?? 'Not Assigned';
    final address = booking['address'] ?? 'No Address';
    final problem = booking['problem'] ?? 'No problem description';

    final statusConfig = _getStatusConfig(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getServiceIcon(service),
                      color: appPrimaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Service Info - FIX: Added Expanded to prevent overflow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '📅 $date • ⏰ $time',
                          style: TextStyle(
                            color: appSecondaryColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge - FIX: Added constraints
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 80,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusConfig.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusConfig.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusConfig.label,
                      style: TextStyle(
                        color: statusConfig.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Details
              _buildDetailItem(Icons.engineering, engineerName),
              const SizedBox(height: 6),
              _buildDetailItem(Icons.location_on, address, maxLines: 2),
              const SizedBox(height: 6),
              _buildDetailItem(Icons.build, _truncateProblem(problem), maxLines: 2),
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                children: [
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: appPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // View Details Button
                  OutlinedButton(
                    onPressed: () => _showBookingDetails(context, booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appPrimaryColor,
                      side: BorderSide(color: appPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: appSecondaryColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: appSecondaryColor,
              fontSize: 13,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showBookingDetails(BuildContext context, Map booking) {
    final scheduledDateTime = booking['scheduledDateTime'] ?? '';
    final price = _extractPriceFromProblem(booking['problem'] ?? '');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: appSurfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: appPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: appPrimaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Details List - FIX: Added SingleChildScrollView for overflow
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Booking ID', booking['bookingId']),
                      _buildDetailRow('Service Type', booking['serviceType']),
                      _buildDetailRow('Service Speed', booking['serviceSpeed']),
                      _buildDetailRow('Status', booking['status']?.toString().toUpperCase()),
                      _buildDetailRow('Date', _formatDate(scheduledDateTime)),
                      _buildDetailRow('Time', _formatTime(scheduledDateTime)),
                      _buildDetailRow('Price', price),
                      _buildDetailRow('Engineer', booking['engineerName']),
                      _buildDetailRow('Engineer Phone', booking['engineerPhone']),
                      _buildDetailRow('Address', booking['address']),
                      _buildDetailRow('Problem', _truncateProblem(booking['problem'] ?? '')),
                      _buildDetailRow('Laptop Count', booking['laptopCount']?.toString()),
                      _buildDetailRow('Booking Mode', booking['bookingMode']),
                      if (booking['otp'] != null)
                        _buildDetailRow('OTP', booking['otp']?.toString()),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    foregroundColor: appSurfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appSecondaryColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'Not scheduled';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTime(String dateTimeString) {
    if (dateTimeString.isEmpty) return 'Not scheduled';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid time';
    }
  }

  String _extractPriceFromProblem(String problem) {
    final regex = RegExp(r'₹(\d+)');
    final match = regex.firstMatch(problem);
    if (match != null) {
      return '₹${match.group(1)}';
    }
    return '₹0';
  }

  String _truncateProblem(String problem) {
    if (problem.length > 60) {
      return '${problem.substring(0, 60)}...';
    }
    return problem;
  }

  IconData _getServiceIcon(String service) {
    if (service.toLowerCase().contains('wifi')) return Icons.wifi;
    if (service.toLowerCase().contains('fast')) return Icons.flash_on;
    if (service.toLowerCase().contains('schedule')) return Icons.schedule;
    return Icons.build;
  }

  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return StatusConfig(Colors.green, 'VERIFIED');
      case 'completed':
        return StatusConfig(Colors.blue, 'COMPLETED');
      case 'cancelled':
        return StatusConfig(Colors.red, 'CANCELLED');
      case 'pending':
        return StatusConfig(Colors.orange, 'PENDING');
      default:
        return StatusConfig(appSecondaryColor, status.toUpperCase());
    }
  }
}

class StatusConfig {
  final Color color;
  final String label;

  StatusConfig(this.color, this.label);
}