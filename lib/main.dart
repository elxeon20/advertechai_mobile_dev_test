import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact us',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String _responseMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Method to submit the form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _responseMessage = ''; // Clear the previous response message
      });

      final String url = 'https://api.byteplex.info/api/test/contact/';
      final Map<String, dynamic> requestBody = {
        'name': _nameController.text,
        'email': _emailController.text,
        'message': _messageController.text,
      };

      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        setState(() {
          _isLoading = false;
        });

        // Check if the form submission was successful
        if (response.statusCode == 201) {
          setState(() {
            _responseMessage = 'Form submitted successfully!';
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to submit form. Please try again.';
          });
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
          _responseMessage = 'Failed to send data, server is not responding';
        });
      }
    }
  }

  // Method to validate the email format
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  // Method to build a text field with an icon
  Widget _buildTextFieldWithIcon(
    TextEditingController controller,
    String labelText,
    String iconPath,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                iconPath,
                width: 44,
                height: 44,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: labelText,
                  hintStyle: TextStyle(fontSize: 13),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return '$labelText is required';
                  }
                  if (!isEmailValid(value)) {
                    setState(() {
                      _responseMessage = 'Email is incorrect';
                    });
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _messageController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 23,
            fontFamily: 'shoika',
          ),
        ),
        backgroundColor: Colors.white10,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFieldWithIcon(
                _nameController,
                'Name',
                'images/icon_lock.jpg',
              ),
              SizedBox(height: 16),
              _buildTextFieldWithIcon(
                _emailController,
                'Email',
                'images/icon_lock.jpg',
              ),
              SizedBox(height: 16),
              _buildTextFieldWithIcon(
                _messageController,
                'Message',
                'images/icon_lock.jpg',
              ),
              SizedBox(height: 70),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading || !isFormValid ? null : _submitForm,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF986D8E)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? Text(
                          'Please wait...',
                          style: TextStyle(
                            fontSize: 23,
                            fontFamily: 'Noyh',
                          ),
                        )
                      : Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 23,
                            fontFamily: 'Noyh',
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              if (_responseMessage.isNotEmpty)
                Text(
                  _responseMessage,
                  style: TextStyle(
                    color: _responseMessage.startsWith('Failed') ||
                            _responseMessage.startsWith('Email')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
