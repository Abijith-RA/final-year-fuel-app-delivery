import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'waiting_list_screen.dart';

class DocumentSubmissionPage extends StatefulWidget {
  final String email;
  final String name;

  const DocumentSubmissionPage({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  _DocumentSubmissionPageState createState() => _DocumentSubmissionPageState();
}

class _DocumentSubmissionPageState extends State<DocumentSubmissionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _findUserDocument();
  }

  Future<void> _findUserDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot =
          await _firestore
              .collection('deliboyrequest')
              .where('email', isEqualTo: widget.email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _documentId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding document: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendDocuments() async {
    final String subject = 'Document Submission for Delivery Boy Application';
    final String body =
        'Hello RapidFill Team,\n\nI am ${widget.name} and I have submitted my application for the delivery boy position. Please find attached my Aadhar Card and Driving License documents for verification.\n\nRegards,\n${widget.name}';

    // First try the direct mailto approach
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: 'rapidafil2025@gmail.com',
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
        // Wait a bit to ensure email client is opened
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitingListScreen()),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('Mailto error: $e');
    }

    // If mailto fails, try the Gmail-specific intent
    final gmailUri = Uri(
      scheme: 'https',
      host: 'mail.google.com',
      path: '/mail/u/0/',
      queryParameters: {
        'view': 'cm',
        'fs': '1',
        'to': 'rapidafil2025@gmail.com',
        'su': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitingListScreen()),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('Gmail error: $e');
    }

    // If both fail, show error dialog
    if (mounted) {
      _showEmailErrorDialog();
    }
  }

  void _showEmailErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Email Error'),
            content: const Text(
              'Could not launch an email client. Please ensure you have an email app installed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openEmailAppStore();
                },
                child: const Text('Install Gmail'),
              ),
            ],
          ),
    );
  }

  Future<void> _openEmailAppStore() async {
    final playStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.google.android.gm',
    );

    try {
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Cancel Application Process?',
              style: TextStyle(color: Colors.orange),
            ),
            content: const Text(
              'If you go back now, your application will be canceled. Do you want to continue?',
              style: TextStyle(color: Colors.orange),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Stay Here',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldExit == true && _documentId != null) {
      try {
        await _firestore.collection('deliboyrequest').doc(_documentId).delete();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting application: ${e.toString()}'),
            ),
          );
        }
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Document Submission',
            style: TextStyle(color: Colors.orange),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.orange),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        backgroundColor: Colors.black,
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Information Message
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.document_scanner,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Document Submission Required',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please send clear copies of the following documents to complete your application:',
                              style: TextStyle(color: Colors.orange),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Front and Back of Aadhar Card',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Front and Back of Driving License',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Our team will verify your documents and update your application status within 3-5 working days.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _sendDocuments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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
                            'Send Documents via Email',
                            style: TextStyle(fontSize: 18),
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
