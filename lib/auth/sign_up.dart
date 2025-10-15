import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_demo/style/textfield_style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = ['Admin', 'User'];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || _selectedRole == null) {
      _showMessage("Fill all fields");
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'role': _selectedRole,
      });

      _showMessage("Registered successfully!");
      Navigator.pushNamed(context, '/loginPage');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Registration failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.business_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(controller: _fullNameController, decoration: textFieldDecoration("Fullname"),),
              const SizedBox(height: 10),
              TextField(controller: _emailController, decoration: textFieldDecoration("Email"),),
              const SizedBox(height: 10),
              TextField(controller: _phoneController, decoration: textFieldDecoration("Phone Number"),),
              const SizedBox(height: 10),
              TextField(controller: _passwordController, obscureText: true, decoration: textFieldDecoration("Password"),),
              const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              decoration: textFieldDecoration("Select Role"),
            ),
            const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: _register,
                        child: const Text("Sign Up",style: TextStyle(color: Colors.black),),
                      ),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Already have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
