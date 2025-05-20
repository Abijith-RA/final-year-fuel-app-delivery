import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirm_buttons.dart';

class ConformList extends StatelessWidget {
  const ConformList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Order List', style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('confirmorder')
              .get(const GetOptions(source: Source.serverAndCache)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading orders',
                  style: TextStyle(color: Colors.orange, fontSize: 18),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No orders available',
                  style: TextStyle(color: Colors.orange, fontSize: 18),
                ),
              );
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              cacheExtent: 1000,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return OrderCard(
                  orderId: order['orderId'],
                  name: order['name'],
                  phone: order['phone'],
                  address: order['address'],
                  documentId: order.id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String name;
  final String phone;
  final String address;
  final String documentId;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.name,
    required this.phone,
    required this.address,
    required this.documentId,
  }) : super(key: key);

  Future<void> _acceptOrder(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
      );

      // Get the document data first
      final docSnapshot = await FirebaseFirestore.instance
          .collection('confirmorder')
          .doc(documentId)
          .get(const GetOptions(source: Source.server));

      if (docSnapshot.exists) {
        // Use batch write for atomic operation
        final batch = FirebaseFirestore.instance.batch();

        // Add to process collection
        batch.set(
          FirebaseFirestore.instance.collection('process').doc(documentId),
          docSnapshot.data()!,
        );

        // Delete from confirmorder collection
        batch.delete(
          FirebaseFirestore.instance.collection('confirmorder').doc(documentId),
        );

        await batch.commit();

        // Close the dialog first before navigation
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Navigate to confirm buttons page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusUpdater(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      // Close the dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                title: Text(
                  'Order Details',
                  style: TextStyle(color: Colors.orange),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Name: $name',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phone: $phone',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Address: $address',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () async {
                      await _acceptOrder(context);
                    },
                    child: Text(
                      'Accept Order',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: $orderId',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: $name',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Phone: $phone',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
