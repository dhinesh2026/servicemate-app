import 'package:flutter/material.dart';
import 'package:servicemate_app/locationPage/user_current_location.dart';

// Custom Colors for your app
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF1F5F9);
}

class DeliveryLocationScreen extends StatefulWidget {
  final String? currentLocation;
  
  const DeliveryLocationScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  _DeliveryLocationScreenState createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  
  String _selectedAddressType = 'Home';
  String _currentArea = 'Puzhal, Chennai';
  bool _showAddressForm = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null && widget.currentLocation!.isNotEmpty) {
      _currentArea = widget.currentLocation!;
    }
  }

  void _showCustomSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _showAddressForm ? _buildAddressForm() : _buildAddressList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      title: Text(
        _showAddressForm ? 'Add New Address' : 'Saved Addresses',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      leading: _showAddressForm 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _showAddressForm = false;
                });
              },
            )
          : null,
      actions: _showAddressForm 
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 22),
                onPressed: () {},
              ),
            ],
    );
  }

  Widget _buildAddressList() {
    return Column(
      children: [
        // Current Location Card
        Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              title: const Text(
                'Use Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                _currentArea,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
              onTap: () {
                setState(() {
                  _showAddressForm = true;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Add New Address Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showAddressForm = true;
                });
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'ADD NEW ADDRESS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Info Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'Add Multiple Addresses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save your home, work, and other frequently used addresses for faster checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Location Section
          _buildFormSection(
            icon: Icons.my_location_rounded,
            title: 'Current Location',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentArea,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Automatically detected',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Complete Address Section
          _buildFormSection(
            icon: Icons.home_work_rounded,
            title: 'Complete Address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'House/Flat/Block No.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _addressController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Enter your complete address...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide detailed address for accurate delivery',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save As Section
          _buildFormSection(
            icon: Icons.bookmark_rounded,
            title: 'Save As',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAddressTypeOption('Home', Icons.home_rounded),
                    const SizedBox(width: 12),
                    _buildAddressTypeOption('Work', Icons.work_rounded),
                    const SizedBox(width: 12),
                    _buildAddressTypeOption('Other', Icons.location_city_rounded),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Contact Details Section
          _buildFormSection(
            icon: Icons.contact_phone_rounded,
            title: 'Contact Details',
            child: Column(
              children: [
                _buildContactField(
                  'Receiver Name',
                  'Enter receiver\'s name',
                  _receiverNameController,
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),
                _buildContactField(
                  'Phone Number',
                  'Enter phone number',
                  _receiverPhoneController,
                  isPhone: true,
                  icon: Icons.phone_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Save Address Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _saveAddress,
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text(
                'SAVE ADDRESS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showAddressForm = false;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildAddressTypeOption(String type, IconData icon) {
    bool isSelected = _selectedAddressType == type;
    
    Color getColorForType(String type) {
      switch (type.toLowerCase()) {
        case 'home':
          return AppColors.success;
        case 'work':
          return AppColors.primary;
        case 'other':
          return AppColors.accent;
        default:
          return AppColors.primary;
      }
    }
    
    final color = getColorForType(type);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAddressType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactField(String label, String hint, TextEditingController controller, {bool isPhone = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary, size: 20) : null,
            ),
          ),
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_addressController.text.isEmpty || _receiverNameController.text.isEmpty) {
      _showCustomSnackBar('Please fill all required fields', AppColors.error);
      return;
    }

    // Create new address object
    final newAddress = SavedAddress(
      type: _selectedAddressType,
      address: '$_currentArea, ${_addressController.text}',
      phoneNumber: _receiverPhoneController.text.isNotEmpty 
          ? _receiverPhoneController.text 
          : null,
      icon: _getIconForAddressType(_selectedAddressType),
    );

    _showCustomSnackBar('Address saved successfully!', AppColors.success);

    // Return to previous screen with the new address after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context, newAddress);
      }
    });
  }

  IconData _getIconForAddressType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'other':
        return Icons.location_city_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }
}