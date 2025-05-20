import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(color: Colors.orange),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'No profile data',
                style: TextStyle(color: Colors.orange),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                SizedBox(height: 20),
                _buildProfileItem('Name', userData['name'] ?? 'Not provided'),
                _buildProfileItem('Email', userData['email'] ?? 'Not provided'),
                _buildProfileItem(
                  'Employment Type',
                  _formatEmploymentType(userData['employmentType']) ??
                      'Not specified',
                ),
                // Add more fields as needed, excluding password
              ],
            ),
          );
        },
      ),
    );
  }

  String? _formatEmploymentType(String? type) {
    if (type == null) return null;
    return type == 'fulltime'
        ? 'Full Time'
        : type == 'parttime'
        ? 'Part Time'
        : type;
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.orangeAccent, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18)),
          Divider(color: Colors.grey[700]),
        ],
      ),
    );
  }

  Future<DocumentSnapshot> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');

    final snapshot =
        await FirebaseFirestore.instance
            .collection('Rapidboy')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

    return snapshot.docs.first;
  }
}
