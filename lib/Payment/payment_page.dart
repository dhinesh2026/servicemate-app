import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ServicePage/service_options_page.dart';

class PaymentPage extends StatefulWidget {
  final String title;
  final dynamic price;
  final String service;
  final String problem;

  const PaymentPage({
    super.key,
    required this.title,
    required this.price,
    required this.service,
    required this.problem,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _startPayment(); // 🔥 NEW FLOW
  }

  /// 🔥 STEP 1: CREATE ORDER FROM BACKEND
  Future<String> createOrder() async {
    final response = await http.post(
      Uri.parse("https://servicemate.ideonixis.com/payment/create-order"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": widget.price,
        "service": widget.service,
        "problem": widget.problem,
        "membershipId": widget.title,
        "userId": "123", // later login user id
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      return data['orderId'];
    } else {
      throw Exception("Order creation failed");
    }
  }

  /// 🔥 STEP 2: OPEN RAZORPAY
  void _startPayment() async {
    try {
      String orderId = await createOrder();

      var options = {
        'key': 'rzp_live_SgT0xJb7yxo6UK',
        'order_id': orderId, // ✅ IMPORTANT
        'name': widget.title,
        'description': "${widget.service} Membership",
        'prefill': {
          'contact': '9876543210',
          'email': 'test@demo.com',
        },
        'theme': {
          'color': '#007BFF',
        }
      };

      _razorpay.open(options);

    } catch (e) {
      debugPrint("❌ Order Error: $e");
    }
  }

  /// 🔥 STEP 3: VERIFY PAYMENT
  Future<void> verifyPayment(
      String orderId, String paymentId, String signature) async {

    await http.post(
      Uri.parse("https://servicemate.ideonixis.com/payment/verify-payment"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "orderId": orderId,
        "paymentId": paymentId,
        "signature": signature
      }),
    );
  }

  /// 🔹 SUCCESS
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {

    await verifyPayment(
      response.orderId!,
      response.paymentId!,
      response.signature!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Payment Successful"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceOptionsPage(
          service: widget.service,
          problem: widget.problem,
          price: widget.price,
          title: widget.title,
        ),
      ),
    );
  }

  /// 🔹 FAILURE
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Payment Failed"),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }

  /// 🔹 WALLET
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Processing Payment...",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}