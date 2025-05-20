import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderStatusUpdater extends StatefulWidget {
  final String orderId;

  const OrderStatusUpdater({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderStatusUpdaterState createState() => _OrderStatusUpdaterState();
}

class _OrderStatusUpdaterState extends State<OrderStatusUpdater> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _currentStatus = 'location_added'; // Initial status

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
  }

  Future<void> _fetchCurrentStatus() async {
    setState(() => _isLoading = true);
    try {
      final doc =
          await _firestore.collection('process').doc(widget.orderId).get();
      if (doc.exists) {
        setState(
          () => _currentStatus = doc.data()?['status'] ?? 'location_added',
        );
      }
    } catch (e) {
      _showToast("Error fetching status: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('process').doc(widget.orderId).update({
        'status': status,
      });
      setState(() => _currentStatus = status);
      _showToast("Status updated to $status");
    } catch (e) {
      _showToast("Error updating status: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndDeliver() async {
    if (_otpController.text.isEmpty) {
      _showToast("Please enter OTP", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final doc =
          await _firestore.collection('process').doc(widget.orderId).get();
      if (!doc.exists) throw Exception('Order not found');

      final orderOtp = doc.data()?['otp']?.toString();
      if (orderOtp == _otpController.text) {
        await _firestore.collection('process').doc(widget.orderId).update({
          'status': 'delivered',
        });
        setState(() => _currentStatus = 'delivered');
        _showToast("OTP verified. Order delivered!");
        _otpController.clear();
      } else {
        _showToast("Invalid OTP. Please try again.", isError: true);
      }
    } catch (e) {
      _showToast("Error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "ENTER DELIVERY OTP",
              style: TextStyle(color: Colors.orange),
            ),
            content: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter 4-digit OTP",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(context);
                  _verifyOtpAndDeliver();
                },
                child: Text("VERIFY", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
    );
  }

  Widget _buildStatusButton(String status, IconData icon, String label) {
    final statusOrder = [
      'location_added',
      'confirmed',
      'process',
      'dispatched',
      'reachlocation',
      'delivered',
    ];

    final currentIndex = statusOrder.indexOf(_currentStatus);
    final isNextStep =
        currentIndex != -1 && statusOrder.indexOf(status) == currentIndex + 1;

    if (!isNextStep) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed:
            _isLoading
                ? null
                : () =>
                    status == 'delivered'
                        ? _showOtpDialog()
                        : _updateStatus(status),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'UPDATE ORDER STATUS',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false, // Remove back button
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        color: Colors.orange,
                        size: 60,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'ORDER #${widget.orderId}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'STATUS: ${_currentStatus.toUpperCase()}',
                          style: TextStyle(color: Colors.orange, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (_isLoading) CircularProgressIndicator(color: Colors.orange),
                if (!_isLoading) ...[
                  _buildStatusButton(
                    'confirmed',
                    Icons.check_circle,
                    "Confirm Order",
                  ),
                  _buildStatusButton(
                    'process',
                    Icons.autorenew,
                    "Start Processing",
                  ),
                  _buildStatusButton(
                    'dispatched',
                    Icons.local_shipping,
                    "Dispatch Order",
                  ),
                  _buildStatusButton(
                    'reachlocation',
                    Icons.location_pin,
                    "Reached Location",
                  ),
                  _buildStatusButton(
                    'delivered',
                    Icons.verified_user,
                    "Deliver Order",
                  ),
                ],
                SizedBox(height: 20),
                if (_currentStatus == 'delivered')
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          'ORDER DELIVERED SUCCESSFULLY!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
