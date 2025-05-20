import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'document_submission_page.dart';
import 'package:radpidelivery/deliveryboylogin.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showInitialOptions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.orange),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body:
          _showInitialOptions
              ? _buildInitialOptions()
              : const RegistrationForm(),
    );
  }

  Widget _buildInitialOptions() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              Column(
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join Our Delivery Team',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earn money on your schedule',
                    style: TextStyle(
                      color: Colors.orange.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Registration Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // New User Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showInitialOptions = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'START REGISTRATION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[700], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[700], thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryBoyLogin(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ALREADY REGISTERED? LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Benefits Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Why Join Us?',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem('Flexible working hours'),
                    _buildBenefitItem('Competitive earnings'),
                    _buildBenefitItem('Weekly payments'),
                    _buildBenefitItem('Supportive team'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Note Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'NOTE:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will need to provide valid documents (Aadhar Card and Driving License) during registration.',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.orange.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _employmentType;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isUnderAge = false;
  bool _emailAlreadyExists = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.orange,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      int age = DateTime.now().year - picked.year;
      if (DateTime.now().month < picked.month ||
          (DateTime.now().month == picked.month &&
              DateTime.now().day < picked.day)) {
        age--;
      }

      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _ageController.text = age.toString();
        _isUnderAge = age < 18;
      });

      if (_isUnderAge) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be at least 18 years old to apply'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('deliboyrequest')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_employmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select employment type')),
      );
      return;
    }

    if (_isUnderAge) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be at least 18 years old to apply'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _emailAlreadyExists = false;
    });

    try {
      // Check if email already exists
      final emailExists = await _checkEmailExists(_emailController.text);

      if (emailExists) {
        setState(() {
          _emailAlreadyExists = true;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This email is already registered. Please use a different email or login.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Save registration data to Firestore
      await _firestore.collection('deliboyrequest').add({
        'name': _nameController.text,
        'dob': _dobController.text,
        'age': int.parse(_ageController.text),
        'email': _emailController.text,
        'employmentType': _employmentType,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Save email to SharedPreferences for future reference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registeredEmail', _emailController.text);

      if (!mounted) return;

      // Navigate to document submission page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => DocumentSubmissionPage(
                email: _emailController.text,
                name: _nameController.text,
              ),
        ),
      );

      // Clear form after successful submission
      _formKey.currentState!.reset();
      setState(() {
        _employmentType = null;
        _selectedDate = null;
        _isUnderAge = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
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
                      const Icon(Icons.delivery_dining, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Application Requirements:',
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
                    'To apply for the delivery job, you must have:',
                    style: TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.orange),
                      const SizedBox(width: 5),
                      const Text(
                        'Valid Aadhar Card',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.orange),
                      const SizedBox(width: 5),
                      const Text(
                        'Valid Driving License',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'After submitting this form, our team will check the data and accept or reject.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (_isUnderAge)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'You must be at least 18 years old to apply',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.orange),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.orange),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (!RegExp(r'^[a-zA-Z .]+$').hasMatch(value)) {
                  return 'Only letters, spaces and dots are allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Date of Birth Field
            TextFormField(
              controller: _dobController,
              style: const TextStyle(color: Colors.orange),
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                labelStyle: const TextStyle(color: Colors.orange),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: Colors.orange,
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Age Field (auto-calculated)
            TextFormField(
              controller: _ageController,
              style: TextStyle(color: _isUnderAge ? Colors.red : Colors.orange),
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(
                  color: _isUnderAge ? Colors.red : Colors.orange,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isUnderAge ? Colors.red : Colors.orange,
                  ),
                ),
                enabled: false,
              ),
            ),
            if (_isUnderAge)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Minimum age requirement: 18 years',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // Employment Type
            const Text(
              'Employment Type',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
            Row(
              children: [
                Radio(
                  value: 'parttime',
                  groupValue: _employmentType,
                  onChanged: (value) {
                    setState(() {
                      _employmentType = value;
                    });
                  },
                  fillColor: WidgetStateProperty.all(Colors.orange),
                ),
                const Text('Part Time', style: TextStyle(color: Colors.orange)),
                const SizedBox(width: 20),
                Radio(
                  value: 'fulltime',
                  groupValue: _employmentType,
                  onChanged: (value) {
                    setState(() {
                      _employmentType = value;
                    });
                  },
                  fillColor: WidgetStateProperty.all(Colors.orange),
                ),
                const Text('Full Time', style: TextStyle(color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 10),

            // Email Field
            TextFormField(
              controller: _emailController,
              style: TextStyle(
                color: _emailAlreadyExists ? Colors.red : Colors.orange,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: _emailAlreadyExists ? Colors.red : Colors.orange,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailAlreadyExists ? Colors.red : Colors.orange,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailAlreadyExists ? Colors.red : Colors.orange,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailAlreadyExists ? Colors.red : Colors.orange,
                  ),
                ),
                errorText:
                    _emailAlreadyExists
                        ? 'This email is already registered'
                        : null,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (value) {
                if (_emailAlreadyExists) {
                  setState(() {
                    _emailAlreadyExists = false;
                  });
                }
              },
            ),
            const SizedBox(height: 30),

            // Submit Button
            Center(
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.orange)
                      : ElevatedButton(
                        onPressed:
                            _isUnderAge || _emailAlreadyExists
                                ? null
                                : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isUnderAge || _emailAlreadyExists
                                  ? Colors.grey
                                  : Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.delivery_dining),
                            SizedBox(width: 8),
                            Text(
                              'Submit Application',
                              style: TextStyle(fontSize: 18),
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

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
