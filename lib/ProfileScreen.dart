import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prakriti/SignupScreen.dart';
import 'search_history.dart';
import 'privacy.dart';
import 'help_support.dart';
import 'settings.dart';
import 'home_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _HomePageState();
}

class _HomePageState extends State<ProfilePage> {
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Get current user

  @override
  Widget build(BuildContext context) {
    // Ensure the user is logged in
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No user logged in!',
            style: TextStyle(color: Colors.orange, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.pink),
            onPressed: () {}, // Add settings functionality if needed
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid) // Use current user's UID
            .get(), // Fetch user data from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'User data not found!',
                style: TextStyle(color: Colors.orange),
              ),
            );
          }

          var userData = snapshot.data!;
          String userName = userData['username'] ?? 'Name not set';
          String userEmail = userData['email'] ?? 'Email not set';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  userName,
                  style: TextStyle(color: Colors.orange, fontSize: 20),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {}, // Add Edit Profile functionality
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem(
                        context,
                        Icons.history,
                        'Search History',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchHistoryPage()),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.lock,
                        'Privacy',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPage()),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.help,
                        'Help & Support',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpSupportPage()),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.settings,
                        'Settings',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut(); // Sign out
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title,
        style: TextStyle(color: Colors.orange, fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}
