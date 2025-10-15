import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication auth = LocalAuthentication();

  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadBiometricStatus();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No biometric sensor found')));
        return;
      }
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to enable fingerprint login',
      );
      if (authenticated) {
        await prefs.setBool('biometric_enabled', true);
        setState(() {
          _biometricEnabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint login enabled')));
      }
    } else {
      await prefs.setBool('biometric_enabled', false);
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text("No user data found.")));
    }

    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Home"),
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Enable Fingerprint Login",
                    style: TextStyle(fontSize: 16)),
                Switch(
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Full Name: ${_userData!['fullName']}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Email: ${_userData!['email']}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Phone: ${_userData!['phone']}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Role: ${_userData!['role']}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

