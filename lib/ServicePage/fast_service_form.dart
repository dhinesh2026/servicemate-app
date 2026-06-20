import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../ServicePage/review_booking_page.dart';

class FastServicePage extends StatefulWidget {
  final String service;
  final String problem;
  final dynamic price;
  final String serviceKey;
  final String title;

  const FastServicePage({
    super.key,
    required this.service,
    required this.problem,
    required this.price,
    required this.serviceKey,
    required this.title,
  });

  @override
  State<FastServicePage> createState() => _FastServicePageState();
}

class _FastServicePageState extends State<FastServicePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final modelController = TextEditingController();
  final problemController = TextEditingController();
  final addressController = TextEditingController();
  final laptopCountController = TextEditingController();
  final companyNameCtrl = TextEditingController();
  final companyIdCtrl = TextEditingController();
  final companyPhoneCtrl = TextEditingController();
  final othersCtrl = TextEditingController();

  File? problemImage;
  String bookingMode = "Self";
  String selfOption = "Home";
  bool isLoading = false;
  double? latitude = 0.0;
  double? longitude = 0.0;

  @override
  void initState() {
    super.initState();
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
    companyNameCtrl.dispose();
    companyIdCtrl.dispose();
    companyPhoneCtrl.dispose();
    othersCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => problemImage = File(pickedFile.path));
    }
  }

  Future<void> submitFastService() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString("fcmToken");

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
        "fcmToken": fcmToken,
        "serviceKey": widget.serviceKey,
      };

      if (bookingMode == "Self") {
        bookingData["selfOption"] =
            selfOption == "Others" ? othersCtrl.text.trim() : selfOption;
      } else {
        bookingData["companyName"] = companyNameCtrl.text.trim();
        bookingData["companyId"] = companyIdCtrl.text.trim();
        bookingData["companyPhone"] = companyPhoneCtrl.text.trim();
      }

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewBookingPage(
            bookingData: bookingData,
            problemImage: problemImage,
          ),
        ),
      );
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // ✅ Fixed Address Search Field
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
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
              debounceTime: 800,
              countries: const ["in"],
              isLatLngRequired: true, // ✅ Important for lat/lng
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // ✅ Capture lat/lng properly
                if (prediction.lat != null && prediction.lng != null) {
                  setState(() {
                    latitude = double.tryParse(prediction.lat ?? "0.0");
                    longitude = double.tryParse(prediction.lng ?? "0.0");
                  });
                }
              },
              itemClick: (Prediction prediction) {
                // ✅ Properly update text and keep typing smooth
                addressController.text = prediction.description ?? "";
                addressController.selection = TextSelection.fromPosition(
                  TextPosition(offset: addressController.text.length),
                );
                FocusScope.of(context).unfocus();
              },
              validator: (val, context) =>
                  val == null || val.isEmpty ? "Enter address" : null,
            ),
          ),
        ],
      ),
    );
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
          widget.title.isNotEmpty ? widget.title : widget.service,
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

              // ✅ Address Field
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
                  onPressed: isLoading ? null : submitFastService,
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
                          "Book Fast Service",
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
