import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _loading = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Email/password login
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Enter email and password");
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _showMessage("Logged in successfully!");
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  // Fingerprint login button
  Future<void> _loginWithBiometric() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && _auth.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage("Fingerprint authentication failed");
      }
    } catch (e) {
      _showMessage("Biometric error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registerPage');
              },
              child: const Text("Don't have an account? Register"),
            ),
            const SizedBox(height: 30),

            // Fingerprint login button (only if enabled)
            if (_biometricEnabled)
              Column(
                children: [
                  const Text(
                    "Or login with fingerprint",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, size: 50, color: Colors.blue),
                    onPressed: _loginWithBiometric,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
