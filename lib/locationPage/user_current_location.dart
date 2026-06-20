import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/BaseWidget.dart';
import 'add_address.dart';

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
  static const Color mapBackground = Color(0xFFF1F5F9);
}

class UserCurrentLocation extends StatefulWidget {
  const UserCurrentLocation({super.key});

  @override
  State<UserCurrentLocation> createState() => _UserCurrentLocationState();
}

class _UserCurrentLocationState extends State<UserCurrentLocation> {
  static const String _apiKey = 'AIzaSyBCV-SK7daO9mRpUXULRFtuU3k4z26ovTA';

  final TextEditingController _searchCtrl = TextEditingController();
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  Timer? _debounce;
  List<_PlaceSuggestion> _suggestions = [];
  String _sessionToken = const Uuid().v4();

  String _currentAddress = "Fetching location...";
  LatLng _cameraTarget = const LatLng(13.0827, 80.2707);
  LatLng? _selectedLatLng;

  // Dynamic saved addresses - loaded from SharedPreferences
  List<SavedAddress> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadSavedAddresses();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ---------------------- SharedPreferences Methods ----------------------

  // Load saved addresses from SharedPreferences
  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList('saved_addresses') ?? [];

      setState(() {
        _savedAddresses = addressesJson.map((jsonString) {
          final Map<String, dynamic> data = json.decode(jsonString);
          return SavedAddress.fromJson(data);
        }).toList();
      });

      print('✅ Loaded ${_savedAddresses.length} saved addresses');
    } catch (e) {
      print('❌ Error loading addresses: $e');
      _showCustomSnackBar("Error loading saved addresses", AppColors.error);
    }
  }

  // Save addresses to SharedPreferences
  Future<void> _saveAddressesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = _savedAddresses
          .map((address) => json.encode(address.toJson()))
          .toList();
      await prefs.setStringList('saved_addresses', addressesJson);
      print('✅ Saved ${_savedAddresses.length} addresses to storage');
    } catch (e) {
      print('❌ Error saving addresses: $e');
      _showCustomSnackBar("Error saving address", AppColors.error);
    }
  }

  // Add new address and save to storage
  Future<void> _addNewAddress(SavedAddress newAddress) async {
    setState(() {
      _savedAddresses.add(newAddress);
    });

    await _saveAddressesToStorage();
    _showCustomSnackBar("Address added successfully!", AppColors.success);
  }

  // Remove address from storage
  Future<void> _removeAddress(int index) async {
    if (index >= 0 && index < _savedAddresses.length) {
      final removedAddress = _savedAddresses[index];
      setState(() {
        _savedAddresses.removeAt(index);
      });

      await _saveAddressesToStorage();
      _showCustomSnackBar(
        "${removedAddress.type} address removed",
        AppColors.success,
      );
    }
  }

  // Clear all addresses
  Future<void> _clearAllAddresses() async {
    setState(() {
      _savedAddresses.clear();
    });

    await _saveAddressesToStorage();
    _showCustomSnackBar("All addresses cleared", AppColors.success);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------------- Location helpers ----------------------

  Future<void> _initLocation() async {
    final addr = await _getCurrentLocation();
    if (addr == null) return;
  }

  Future<String?> _getCurrentLocation() async {
    _showCustomSnackBar("Getting your current location...", AppColors.primary);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentAddress = "Location services are disabled.");
      _showCustomSnackBar("Please enable location services", AppColors.warning);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentAddress = "Location permission denied.");
        _showCustomSnackBar("Location permission denied", AppColors.error);
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(
        () => _currentAddress = "Location permission permanently denied.",
      );
      _showCustomSnackBar(
        "Location permission permanently denied",
        AppColors.error,
      );
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selectedLatLng = LatLng(pos.latitude, pos.longitude);
      _cameraTarget = _selectedLatLng!;
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _selectedLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final area = p.subLocality ?? "";
        final city = p.locality ?? "";
        final finalAddress = area.isNotEmpty ? "$area, $city" : city;
        setState(() {
          _currentAddress = finalAddress.isEmpty
              ? "Address not found"
              : finalAddress;
        });
        _animateTo(_selectedLatLng!);
        _showCustomSnackBar("Location found successfully!", AppColors.success);
        return finalAddress;
      } else {
        setState(() => _currentAddress = "Address not found");
        _showCustomSnackBar(
          "Could not find address details",
          AppColors.warning,
        );
        return null;
      }
    } catch (e) {
      setState(() => _currentAddress = "Error getting location");
      _showCustomSnackBar("Error getting location: $e", AppColors.error);
      return null;
    }
  }

  void _animateTo(LatLng target, {double zoom = 16}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  // ---------------------- Autocomplete ----------------------

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final input = _searchCtrl.text.trim();
      if (input.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      _fetchAutocomplete(input);
    });
  }

  Future<void> _fetchAutocomplete(String input) async {
    final biasCenter = _selectedLatLng ?? _cameraTarget;

    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );
    final body = {
      "input": input,
      "sessionToken": _sessionToken,
      "locationBias": {
        "circle": {
          "center": {
            "latitude": biasCenter.latitude,
            "longitude": biasCenter.longitude,
          },
          "radius": 50000.0,
        },
      },
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        setState(() => _suggestions = []);
        return;
      }

      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<dynamic> suggestions = (data['suggestions'] as List?) ?? [];

      final parsed = suggestions
          .map<_PlaceSuggestion>((s) {
            final placePred = s['placePrediction'] ?? {};
            final placeId = placePred['placeId'] as String? ?? '';

            String primary = s['structuredFormat']?['mainText']?['text'] ?? '';
            String secondary =
                s['structuredFormat']?['secondaryText']?['text'] ?? '';
            String text = s['text']?['text'] ?? '';

            String display = primary.isNotEmpty
                ? (secondary.isNotEmpty ? '$primary, $secondary' : primary)
                : text;

            return _PlaceSuggestion(placeId: placeId, display: display);
          })
          .where((e) => e.placeId.isNotEmpty && e.display.isNotEmpty)
          .toList();

      setState(() => _suggestions = parsed);
    } catch (e) {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _selectSuggestion(_PlaceSuggestion s) async {
    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places/${Uri.encodeComponent(s.placeId)}',
    );
    final res = await http.get(
      uri,
      headers: {
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
      },
    );

    if (res.statusCode != 200) return;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final loc = (data['location'] as Map?) ?? {};
    final lat = (loc['latitude'] as num?)?.toDouble();
    final lng = (loc['longitude'] as num?)?.toDouble();
    final formatted = (data['formattedAddress'] as String?) ?? s.display;

    if (lat != null && lng != null) {
      final target = LatLng(lat, lng);
      setState(() {
        _selectedLatLng = target;
        _currentAddress = formatted;
        _suggestions = [];
        _markers
          ..clear()
          ..add(
            Marker(
              markerId: const MarkerId('selected_location'),
              position: target,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(title: formatted),
            ),
          );
      });
      _animateTo(target);
      _sessionToken = const Uuid().v4();
      _showCustomSnackBar("Location selected: $formatted", AppColors.success);
    }
  }

  // ---------------------- Handle New Address ----------------------

  void _handleNewAddress(SavedAddress newAddress) {
    _addNewAddress(newAddress);
  }

  Widget _buildAddressTypeIcon(String type, IconData icon) {
    Color iconColor;
    Color backgroundColor;

    switch (type.toLowerCase()) {
      case 'home':
        iconColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
        break;
      case 'work':
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        break;
      default:
        iconColor = AppColors.accent;
        backgroundColor = AppColors.accent.withOpacity(0.1);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(int index) {
    final address = _savedAddresses[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Address?"),
          content: Text(
            "Are you sure you want to delete your ${address.type} address?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeAddress(index);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          title: const Text(
            "Select Location",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_savedAddresses.isNotEmpty)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _clearAllAddresses();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Clear All Addresses'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            // Search Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        hintText: "Search for area, street name...",
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Current Location Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        "Use Current Location",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _currentAddress,
                        style: const TextStyle(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () async {
                        final addr = await _getCurrentLocation();
                        if (addr != null && mounted) {
                          Navigator.pop(
                            context,
                            addr,
                          ); // ← address-ஐ home-க்கு return பண்ணு
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions List
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) {
                    final s = _suggestions[i];
                    return ListTile(
                      leading: Icon(
                        Icons.place_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      title: Text(
                        s.display,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _selectSuggestion(s),
                    );
                  },
                ),
              ),

            // Quick Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final newAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryLocationScreen(
                              currentLocation: _currentAddress,
                            ),
                          ),
                        );
                        if (newAddress != null && newAddress is SavedAddress) {
                          _handleNewAddress(newAddress);
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text("Add New Address"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Saved Addresses Section
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "SAVED ADDRESSES (${_savedAddresses.length})",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Addresses List or Empty State
                    if (_savedAddresses.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_rounded,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Saved Addresses",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add your first address to get started",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = _savedAddresses[index];
                            return Dismissible(
                              key: Key('address_${index}_${address.address}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: AppColors.error,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                _showDeleteDialog(index);
                                return false; // We handle deletion in the dialog
                              },
                              child: Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: _buildAddressTypeIcon(
                                    address.type,
                                    address.icon,
                                  ),
                                  title: Text(
                                    address.type,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.address,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (address.phoneNumber != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          "Phone: ${address.phoneNumber}",
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, address.address);
                                  },
                                  onLongPress: () => _showDeleteDialog(index),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class _PlaceSuggestion {
  final String placeId;
  final String display;
  _PlaceSuggestion({required this.placeId, required this.display});
}

class SavedAddress {
  final String type;
  final String address;
  final String? phoneNumber;
  final IconData icon;

  SavedAddress({
    required this.type,
    required this.address,
    this.phoneNumber,
    required this.icon,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'address': address,
      'phoneNumber': phoneNumber,
      'icon': type,
    };
  }

  // Create from JSON
  factory SavedAddress.fromJson(Map<String, dynamic> json) {
  return SavedAddress(
    type: json['type'],
    address: json['address'],
    phoneNumber: json['phoneNumber'],
    icon: _getIconFromType(json['type']),
  );
}

}

IconData _getIconFromType(String type) {
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
