import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ServicePage/review_booking_page_schedule.dart';

class ScheduleServicePage extends StatefulWidget {
  final String service; // Service name
  final String problem; // Problem description
  final dynamic price; // Price
  final String serviceKey;
  final String title;

  const ScheduleServicePage({
    super.key,
    required this.service,
    required this.problem,
    required this.price,
    required this.serviceKey,
    required this.title,
  });

  @override
  State<ScheduleServicePage> createState() => _ScheduleServicePageState();
}

class _ScheduleServicePageState extends State<ScheduleServicePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final modelController = TextEditingController();
  final problemController = TextEditingController();
  final addressController = TextEditingController();
  final laptopCountController = TextEditingController();
  final scheduleDateController = TextEditingController();
  final scheduleTimeController = TextEditingController();

  final companyNameCtrl = TextEditingController();
  final companyIdCtrl = TextEditingController();
  final companyPhoneCtrl = TextEditingController();
  final othersCtrl = TextEditingController();

  File? problemImage;

  String bookingMode = "Self"; // Self / Partnership
  String selfOption = "Home"; // Home / Office / Others
  bool isLoading = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    // Auto-location feature removed - no more _fillCurrentAddress()
    
    // Pre-fill problem description with selected problem + price
    problemController.text = "${widget.problem} (₹${widget.price ?? 'N/A'})";
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    modelController.dispose();
    problemController.dispose();
    addressController.dispose();
    laptopCountController.dispose();
    scheduleDateController.dispose();
    scheduleTimeController.dispose();
    companyNameCtrl.dispose();
    companyIdCtrl.dispose();
    companyPhoneCtrl.dispose();
    othersCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null)
      setState(() => problemImage = File(pickedFile.path));
  }

  Future<void> pickScheduleDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      scheduleDateController.text =
          "${picked.day}-${picked.month}-${picked.year}";
    }
  }

  Future<void> pickScheduleTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      scheduleTimeController.text = picked.format(context);
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ✅ Address field with only Google Places autocomplete - no auto-location
  Widget buildAddressSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Address",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: addressController,
              googleAPIKey: "AIzaSyBCV-SK7daO9mRpUXULRFtuU3k4z26ovTA",
              inputDecoration: const InputDecoration(
                hintText: "Enter your address",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
              debounceTime: 800,
              countries: const ["in"],
              isLatLngRequired: false,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // You can get latitude and longitude here if needed
                if (prediction.lat != null && prediction.lng != null) {
                  latitude = double.tryParse(prediction.lat!);
                  longitude = double.tryParse(prediction.lng!);
                }
              },
              itemClick: (Prediction prediction) {
                addressController.text = prediction.description ?? "";
                addressController.selection = TextSelection.fromPosition(
                  TextPosition(offset: addressController.text.length),
                );
              },
              validator: (val, context) =>
                  val == null || val.isEmpty ? "Enter address" : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitScheduleService() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString("fcmToken");
      print("fcmmmmmmm: $fcmToken");
      
      Map<String, dynamic> bookingData = {
        "userName": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "model": modelController.text.trim(),
        "problem": problemController.text.trim(),
        "laptopCount": laptopCountController.text.trim(),
        "address": addressController.text.trim(),
        "lat": latitude,
        "lng": longitude,
        "serviceType": widget.service,
        "bookingMode": bookingMode,
        "scheduleDate": scheduleDateController.text,
        "scheduleTime": scheduleTimeController.text,
        "fcmToken": fcmToken,
        "serviceKey": widget.serviceKey,
      };

      print("scccccccccc: $bookingData");

      if (bookingMode == "Self") {
        bookingData["selfOption"] = selfOption == "Others"
            ? othersCtrl.text.trim()
            : selfOption;
      } else {
        bookingData["companyName"] = companyNameCtrl.text.trim();
        bookingData["companyId"] = companyIdCtrl.text.trim();
        bookingData["companyPhone"] = companyPhoneCtrl.text.trim();
      }

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScheduleBookingPage(
            bookingData: bookingData,
            problemImage: problemImage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          (widget.title.isNotEmpty ? widget.title : widget.service),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                "Service - ${widget.service}",
                TextEditingController(text: widget.service),
                readOnly: true,
              ),
              buildTextField(
                "Name",
                nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your name" : null,
              ),
              buildTextField(
                "Phone Number",
                phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter phone number";
                  if (val.length != 10) return "Enter 10 digit number";
                  return null;
                },
              ),
              buildTextField(
                "${widget.service} Brand/Model",
                modelController,
                validator: (val) => val == null || val.isEmpty
                    ? "Enter ${widget.service} model"
                    : null,
              ),
              buildTextField(
                "Problem Description",
                problemController,
                maxLines: 3,
                readOnly: true,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter problem details" : null,
              ),
              buildTextField(
                "Number of ${widget.service}",
                laptopCountController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty
                    ? "Enter number of ${widget.service}"
                    : null,
              ),
              buildTextField(
                "Schedule Date",
                scheduleDateController,
                readOnly: true,
                validator: (val) =>
                    val == null || val.isEmpty ? "Select schedule date" : null,
                onTap: pickScheduleDate,
              ),
              buildTextField(
                "Schedule Time",
                scheduleTimeController,
                readOnly: true,
                validator: (val) =>
                    val == null || val.isEmpty ? "Select schedule time" : null,
                onTap: pickScheduleTime,
              ),
              // ✅ Clean Address field with only Google Places autocomplete
              buildAddressSearchField(),
              const Divider(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Booking Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Self",
                    groupValue: bookingMode,
                    onChanged: (val) => setState(() => bookingMode = val!),
                  ),
                  const Text("Self"),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: "Partnership",
                    groupValue: bookingMode,
                    onChanged: (val) => setState(() => bookingMode = val!),
                  ),
                  const Text("Partnership"),
                ],
              ),
              if (bookingMode == "Self") ...[
                DropdownButtonFormField<String>(
                  value: selfOption,
                  items: const [
                    DropdownMenuItem(value: "Home", child: Text("Home")),
                    DropdownMenuItem(value: "Office", child: Text("Office")),
                    DropdownMenuItem(value: "Others", child: Text("Others")),
                  ],
                  onChanged: (val) => setState(() => selfOption = val!),
                  decoration: const InputDecoration(
                    labelText: "Select Option",
                    border: OutlineInputBorder(),
                  ),
                ),
                if (selfOption == "Others")
                  buildTextField(
                    "Please specify",
                    othersCtrl,
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter details for Others"
                        : null,
                  ),
              ],
              if (bookingMode == "Partnership") ...[
                buildTextField(
                  "Company Name",
                  companyNameCtrl,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter company name" : null,
                ),
                buildTextField(
                  "Company ID",
                  companyIdCtrl,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter company ID" : null,
                ),
                buildTextField(
                  "Company Phone",
                  companyPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return "Enter company phone";
                    if (val.length != 10) return "Enter 10 digit phone";
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Upload Photo"),
                  ),
                  const SizedBox(width: 10),
                  if (problemImage != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipOval(
                          child: Image.file(
                            problemImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => problemImage = null),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text("No Image"),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitScheduleService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Book Schedule Service",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}