import 'package:flutter/material.dart';
import 'register_screen.dart'; // Update with your actual path

class WaitingListScreen extends StatelessWidget {
  const WaitingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, we'll use a hardcoded status
    final status = 'pending'; // Change to 'approved' to see different UI
    final name = 'John Doe'; // Example name

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Application Status',
          style: TextStyle(color: Colors.orange),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == 'approved'
                    ? Icons.check_circle
                    : Icons.hourglass_empty,
                size: 100,
                color: status == 'approved' ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                status == 'approved'
                    ? 'Congratulations $name!'
                    : 'Your Application is Under Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: status == 'approved' ? Colors.green : Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: status == 'approved' ? Colors.green : Colors.orange,
                  ),
                ),
                child: Text(
                  status == 'approved'
                      ? 'Your application has been approved!\n\n'
                          'Your login credentials have been sent to your registered email address. '
                          'Please check your inbox (and spam folder) for your username and temporary password.\n\n'
                          'You can now login to the delivery app and start accepting orders.'
                      : 'Thank you for submitting your application and documents $name.\n\n'
                          'Our admin team is currently validating your information and documents. '
                          'This process usually takes 3-5 working days.\n\n'
                          'Once approved, you will receive an email with your login credentials. '
                          'If it takes longer than expected, please check your email regularly as we may '
                          'need additional information from you.',
                  style: TextStyle(
                    color: status == 'approved' ? Colors.green : Colors.orange,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to RegisterScreen (login page)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == 'approved' ? Colors.green : Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Return to Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              if (status == 'approved') ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to main delivery app
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
