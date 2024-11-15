  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
  import 'package:app/home.dart';
  import 'package:app/login.dart'; // Make sure to import the Login screen

  class DashboardScreen extends StatelessWidget {
    const DashboardScreen({super.key});

    Future<void> logout(BuildContext context) async {
      // Here you can add any logout logic if necessary, such as clearing user session data.
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Redirect to Login screen
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          backgroundColor: Colors.brown[700], // Set AppBar background to brown
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh , color: Colors.white,),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded , color: Colors.white,), // Logout button
              
              onPressed: () => logout(context), // Call logout function on press
            ),
            IconButton(
              icon: const Icon(Icons.more_vert , color: Colors.white,),
              onPressed: () {},
            ),
          ],
        ),
        body: Container(
          color: Colors.brown[50], // Light brown background for body
          child: ListView(
            children: [
              dashboardItem(
                "Cattle Tagging",
                "https://t3.ftcdn.net/jpg/09/65/25/28/360_F_965252897_T3YpmElZMDK5KJg9kFYhAZm9c9wTja6f.jpg",
                context,
                navigateToHome: true,
              ),
              dashboardItem(
                "Cattle Claims",
                "https://img.freepik.com/free-psd/beautiful-cow-picture_23-2151840282.jpg?t=st=1731332870~exp=1731336470~hmac=43eb22b647cd1d990e340d4e638d9e51e446c51c01f01d995696f8f8f82b9d34&w=996",
                context,
                navigateToHome: false,
              ),
            ],
          ),
        ),
      );
    }

    Widget dashboardItem(String title, String imageUrl, BuildContext context, {bool navigateToHome = false}) {
      return InkWell(
        onTap: () {
          if (navigateToHome) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            elevation: 4.0,
            color: Colors.brown[100], // Light brown card color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rounded corners for the card
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
                  height: 300.0, // Adjust image height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300.0,
                      color: Colors.grey,
                      child: const Center(
                        child: Text(
                          'Could not load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown, // Dark brown text color
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
