import 'package:flutter/material.dart';

class ProfilePembeli extends StatefulWidget {
  const ProfilePembeli({super.key});

  @override
  State<ProfilePembeli> createState() => _ProfilePembeliState();
}

class _ProfilePembeliState extends State<ProfilePembeli> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Pembeli"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selamat Datang di Halaman Profile Pembeli",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
