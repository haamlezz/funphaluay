import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testproject/appcolor.dart';
import 'package:testproject/pages/add_page.dart';
import 'package:testproject/pages/login_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profileImage;
  String? userEmail;
  String? profileImageUrl;
  static const String specificEmail = "vongthavone@gmail.com";

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage(email: '')),
      (Route<dynamic> route) => false,
    );
  }

  void _getCurrentUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
      _emailController.text = user?.email ?? '';
      _nameController.text = user?.displayName ?? '';
      profileImageUrl = user?.photoURL;
    });
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update profile details
      await user.updateProfile(
          displayName: _nameController.text, photoURL: profileImageUrl);
      if (_emailController.text != user.email) {
        // ignore: deprecated_member_use
        await user.updateEmail(_emailController.text);
      }
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      // Reload user to get updated details
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      setState(() {
        userEmail = user?.email;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String filePath = 'profile_images/${user.uid}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

    try {
      await storageRef.putFile(_profileImage!);
      String downloadUrl = await storageRef.getDownloadURL();

      await user.updateProfile(photoURL: downloadUrl);
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ບັນຊີ"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ຂໍ້ມູນຜູ້ໃຊ້",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ຊື່-ນາມສະກຸນ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'ລະຫັດໃໝ່',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("ບັນທຶກ"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _logout,
                child: const Text("ອອກຈາກລະບົບ"),
              ),
              const SizedBox(height: 20),
              specificEmail == userEmail
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddPage(),
                          ),
                        );
                      },
                      child: const Text("ເພີ່ມເລກ"),
                    )
                  : const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
