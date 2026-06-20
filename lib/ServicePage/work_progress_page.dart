// lib/screens/work_progress_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Payment/service_payment_page.dart';

class WorkProgressPage extends StatefulWidget {
  final String bookingId;
  final String engineerName;
  final String engineerPhone;
  final String serviceType;
  final String problem;
  final String model;
  final String selfieImage;

  const WorkProgressPage({
    super.key,
    required this.bookingId,
    required this.engineerName,
    required this.engineerPhone,
    required this.serviceType,
    required this.problem,
    required this.model,
    required this.selfieImage,
  });

  @override
  State<WorkProgressPage> createState() => _WorkProgressPageState();
}

class _WorkProgressPageState extends State<WorkProgressPage> {
  String _currentStatus = 'engineer_reached';
  double _basePrice = 0.0;
  double _additionalServices = 0.0;
  double _gst = 0.0;
  double _totalAmount = 0.0;
  List<Map<String, dynamic>> _additionalServicesList = [];
  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenForWorkUpdates();
  }

  void _listenForWorkUpdates() {
    _statusSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data()!;
        final status = (data['status'] ?? 'engineer_reached').toString();

        debugPrint("📱 Status changed: $status");

        // Fetch pricing data from Firestore
        _fetchPricingDataFromFirestore(data);

        setState(() {
          _currentStatus = status;
          _isLoading = false;
        });

        if (status == 'cancelled') {
          _showCancelledDialog();
        }
      }
    }, onError: (e) {
      debugPrint("❌ Status listener error: $e");
      setState(() => _isLoading = false);
    });
  }

  void _fetchPricingDataFromFirestore(Map<String, dynamic> data) {
    try {
      // Debug: Print all available fields
      _debugFirestoreFields(data);
      
      // Fetch basePrice from Firestore - look for different possible field names
      final basePriceData = data['basePrice'] ?? data['servicePrice'] ?? data['price'];
      if (basePriceData != null) {
        if (basePriceData is num) {
          _basePrice = basePriceData.toDouble();
        } else if (basePriceData is String) {
          _basePrice = double.tryParse(basePriceData) ?? 0.0;
        }
      }

      // Fetch additionalServices from Firestore - handle multiple services
      final additionalServicesData = data['additionalServices'];
      if (additionalServicesData != null) {
        if (additionalServicesData is Map<String, dynamic>) {
          // Handle multiple services structure
          _processAdditionalServicesMap(additionalServicesData);
        } else if (additionalServicesData is num) {
          _additionalServices = additionalServicesData.toDouble();
          _additionalServicesList = []; // Clear list if it's just a number
        } else if (additionalServicesData is String) {
          _additionalServices = double.tryParse(additionalServicesData) ?? 0.0;
          _additionalServicesList = []; // Clear list if it's just a string
        }
      }

      // Fetch GST from Firestore - look for different possible field names
      final gstData = data['gst'] ?? data['tax'] ?? data['gstAmount'];
      if (gstData != null) {
        if (gstData is num) {
          _gst = gstData.toDouble();
        } else if (gstData is String) {
          _gst = double.tryParse(gstData) ?? 0.0;
        }
      }

      // Fetch totalAmount from Firestore - look for different possible field names
      final totalAmountData = data['totalAmount'] ?? data['finalAmount'] ?? data['totalPrice'];
      if (totalAmountData != null) {
        if (totalAmountData is num) {
          _totalAmount = totalAmountData.toDouble();
        } else if (totalAmountData is String) {
          _totalAmount = double.tryParse(totalAmountData) ?? 0.0;
        }
      } else {
        // If totalAmount doesn't exist in Firestore, calculate it
        _calculateTotalAmount();
      }

      debugPrint('💰 Pricing Data from Firestore:');
      debugPrint('   Base Price: $_basePrice');
      debugPrint('   Additional Services Total: $_additionalServices');
      debugPrint('   Number of Additional Services: ${_additionalServicesList.length}');
      debugPrint('   GST: $_gst');
      debugPrint('   Total Amount: $_totalAmount');

    } catch (e) {
      debugPrint("❌ Error fetching pricing data from Firestore: $e");
      // Fallback calculation if Firestore data is not available
      _calculateTotalAmount();
    }
  }

  void _processAdditionalServicesMap(Map<String, dynamic> additionalServicesMap) {
    try {
      _additionalServicesList.clear();
      double totalAdditional = 0.0;

      // Process each service in the additionalServices map
      additionalServicesMap.forEach((serviceName, serviceData) {
        if (serviceData is Map<String, dynamic>) {
          // Extract service details
          final service = _extractServiceDetails(serviceName, serviceData);
          if (service != null) {
            _additionalServicesList.add(service);
            totalAdditional += service['totalPrice'] ?? 0.0;
          }
        }
      });

      _additionalServices = totalAdditional;

      debugPrint('🛠️ Processed ${_additionalServicesList.length} additional services:');
      for (final service in _additionalServicesList) {
        debugPrint('   - ${service['name']}: ₹${service['totalPrice']}');
      }

    } catch (e) {
      debugPrint("❌ Error processing additional services map: $e");
      _additionalServices = _extractAdditionalServicesFromMap(additionalServicesMap);
    }
  }

  Map<String, dynamic>? _extractServiceDetails(String serviceName, Map<String, dynamic> serviceData) {
    try {
      final name = serviceName;
      final isCustom = serviceData['isCustom'] ?? false;
      final quantity = serviceData['quantity'] ?? 1;
      final unitPrice = (serviceData['unitPrice'] ?? serviceData['price'] ?? 0).toDouble();
      final totalPrice = (serviceData['totalPrice'] ?? serviceData['amount'] ?? unitPrice * quantity).toDouble();

      return {
        'name': name,
        'isCustom': isCustom,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };
    } catch (e) {
      debugPrint("❌ Error extracting service details for $serviceName: $e");
      return null;
    }
  }

  void _debugFirestoreFields(Map<String, dynamic> data) {
    debugPrint('🔍 All available fields in Firestore document:');
    data.forEach((key, value) {
      debugPrint('   $key: $value (${value.runtimeType})');
    });
  }

  void _calculateTotalAmount() {
    final subtotal = _basePrice + _additionalServices;
    _gst = _gst == 0.0 ? double.parse((subtotal * 0.18).toStringAsFixed(2)) : _gst;
    _totalAmount = double.parse((subtotal + _gst).toStringAsFixed(2));
  }

  double _extractAdditionalServicesFromMap(Map<String, dynamic> additionalServicesMap) {
    try {
      if (additionalServicesMap['total'] != null) {
        return (additionalServicesMap['total'] as num).toDouble();
      } else if (additionalServicesMap['amount'] != null) {
        return (additionalServicesMap['amount'] as num).toDouble();
      } else if (additionalServicesMap['value'] != null) {
        return (additionalServicesMap['value'] as num).toDouble();
      } else if (additionalServicesMap['price'] != null) {
        return (additionalServicesMap['price'] as num).toDouble();
      } else {
        double sum = 0.0;
        additionalServicesMap.forEach((key, value) {
          if (value is num) {
            sum += value.toDouble();
          }
        });
        return sum;
      }
    } catch (e) {
      debugPrint("❌ Error extracting additional services from map: $e");
      return 0.0;
    }
  }

  void _showCancelledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Cancelled'),
        content: const Text('This booking has been cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment() {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, loading payment details...')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingId: widget.bookingId,
          basePrice: _basePrice,
          additionalServices: _additionalServices,
          gst: _gst,
          totalAmount: _totalAmount,
          engineerName: widget.engineerName,
          serviceType: widget.serviceType,
          problem: _getCleanProblemDescription(),
          model: widget.model,
        ),
      ),
    );
  }

  String _getCleanProblemDescription() {
    String problem = widget.problem;
    problem = problem.replaceAll(RegExp(r'\([¥₹Rs\.\s\d]+\)'), '').trim();
    problem = problem.replaceAll(RegExp(r'[¥₹Rs\.\s]*\d+[\.\d]*'), '').trim();
    return problem.isEmpty ? 'Not specified' : problem;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAdditionalServicesList() {
    if (_additionalServicesList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No additional services",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final service in _additionalServicesList)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] ?? 'Unknown Service',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${service['quantity'] ?? 1} × ₹${(service['unitPrice'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (service['isCustom'] == true)
                        const Text(
                          'Custom Service',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '₹${(service['totalPrice'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPricingDetails() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Breakdown",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildPricingRow("Base Price", "₹${_basePrice.toStringAsFixed(2)}"),
        
        // Additional Services Section
        if (_additionalServicesList.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            "Additional Services:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          _buildAdditionalServicesList(),
          _buildPricingRow("Additional Services Total", "₹${_additionalServices.toStringAsFixed(2)}"),
        ] else if (_additionalServices > 0) ...[
          _buildPricingRow("Additional Services", "₹${_additionalServices.toStringAsFixed(2)}"),
        ],
        
        _buildPricingRow("GST (18%)", "₹${_gst.toStringAsFixed(2)}"),
        const Divider(),
        _buildPricingRow(
          "Total Amount", 
          "₹${_totalAmount.toStringAsFixed(2)}",
          isTotal: true
        ),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Progress"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange[50]!, Colors.blue[50]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.engineering,
                        size: 50,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getStatusHeaderText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Engineer: ${widget.engineerName}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Service Information
              const Text(
                "Service Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard("Engineer", widget.engineerName, Icons.engineering),
                      const Divider(height: 20),
                      _buildInfoCard("Service Type", widget.serviceType, Icons.build),
                      const Divider(height: 20),
                      _buildInfoCard("Device Model", widget.model, Icons.smartphone),
                      const Divider(height: 20),
                      _buildInfoCard("Problem", _getCleanProblemDescription(), Icons.info),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pricing Details Section
              if (_currentStatus == 'work_completed') ...[
                const Text(
                  "Payment Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPricingDetails(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Current Status Section
              const Text(
                "Current Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(_getStatusIcon(), color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getStatusTitle(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getStatusSubtitle(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_currentStatus == 'in_progress') ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Button Section
              if (_currentStatus == 'work_completed') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Work Completed Successfully!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Total Amount: ₹${_totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                          onPressed: _isLoading ? null : _navigateToPayment,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.payment, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      "PROCEED TO PAYMENT",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_currentStatus == 'in_progress') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            "Work In Progress",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Our engineer is currently working on your device. You'll be notified when the work is completed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.engineering, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Engineer Has Arrived",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Our engineer has reached your location and is ready to start the service.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Additional Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getInfoText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusHeaderText() {
    switch (_currentStatus) {
      case 'in_progress':
        return "Work In Progress";
      case 'work_completed':
        return "Work Completed Successfully";
      default:
        return "Engineer Has Reached";
    }
  }

  String _getStatusTitle() {
    switch (_currentStatus) {
      case 'in_progress':
        return "Repairing Your Device";
      case 'work_completed':
        return "Ready for Payment";
      default:
        return "Ready to Start Work";
    }
  }

  String _getStatusSubtitle() {
    switch (_currentStatus) {
      case 'in_progress':
        return "Our engineer is currently working on your ${widget.model}";
      case 'work_completed':
        return "Service completed successfully. Proceed to payment.";
      default:
        return "Engineer ${widget.engineerName} is ready to begin";
    }
  }

  String _getInfoText() {
    switch (_currentStatus) {
      case 'in_progress':
        return "Our engineer is working on your device. This may take some time depending on the complexity of the repair.";
      case 'work_completed':
        return "Your service has been completed. Please proceed with the payment to complete the booking.";
      default:
        return "Our engineer has arrived at your location and will begin the service shortly.";
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'in_progress':
        return Colors.orange;
      case 'work_completed':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case 'in_progress':
        return Icons.build;
      case 'work_completed':
        return Icons.check_circle;
      default:
        return Icons.engineering;
    }
  }
}