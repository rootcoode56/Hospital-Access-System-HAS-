import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:has/main.dart';
import 'package:has/updateprofilepage.dart';
import 'package:path_provider/path_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final List<String> announcements = [
    "Welcome to HAS!",
    "Free health checkup on Friday",
    "New specialist doctors added!",
    "24/7 Emergency Services Available",
  ];

  int _currentAnnouncementIndex = 0;
  late Timer _announcementTimer;

  String _localUserName = "User";
  File? _localUserPhotoFile;

  @override
  void initState() {
    super.initState();
    _startAnnouncementRotation();
    _loadLocalUserProfile(); // load name & photo from local JSON
  }

  void _startAnnouncementRotation() {
    _announcementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentAnnouncementIndex =
            (_currentAnnouncementIndex + 1) % announcements.length;
      });
    });
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/user_profile.json';
  }

  Future<void> _loadLocalUserProfile() async {
    try {
      final path = await _getLocalFilePath();
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> userData = jsonDecode(jsonString);

        setState(() {
          _localUserName = userData['name'] ?? "User";

          final imagePath = userData['profileImagePath'] ?? '';
          if (imagePath.isNotEmpty) {
            final imgFile = File(imagePath);
            if (imgFile.existsSync()) {
              _localUserPhotoFile = imgFile;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Failed to load profile: $e");
    }
  }

  @override
  void dispose() {
    _announcementTimer.cancel();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CroppedBackgroundScreen(),
        ),
      );
    }
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, '/$routeName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Announcement box
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        height: 40,
                        width: 320,
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          child: Text(
                            announcements[_currentAnnouncementIndex],
                            key: ValueKey<String>(
                              announcements[_currentAnnouncementIndex],
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'TanjimFonts',
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Top section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/updateProfile',
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                backgroundImage: _localUserPhotoFile != null
                                    ? FileImage(_localUserPhotoFile!)
                                    : const AssetImage('assets/avater.png')
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Transform.translate(
                              offset: const Offset(-6, 0),
                              child: GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/account'),
                                child: Text(
                                  _localUserName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'TanjimFonts',
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UpdateProfilePage(),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const ui.Color.fromARGB(
                                      255,
                                      205,
                                      174,
                                      174,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Image.asset(
                                    "assets/HAS.png",
                                    width: 100,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Glassy box with buttons (blur effect)
                SizedBox(
                  height: 550,
                  child: Stack(
                    children: [
                      // Blackish background
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // Blur effect
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(
                                0,
                              ), // transparent overlay
                            ),
                          ),
                        ),
                      ),
                      // GridView on top
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          children: [
                            _buildDashboardButton(
                              "Search Symptoms",
                              "assets/Mag.jpg",
                              "search",
                            ),
                            _buildDashboardButton(
                              "Specialist",
                              "assets/Specialist.jpg",
                              "specialist",
                            ),
                            _buildDashboardButton(
                              "Booking",
                              "assets/Booking.jpg",
                              "booking",
                            ),
                            _buildDashboardButton(
                              "HAS Near me",
                              "assets/Map.jpg",
                              "nearby",
                            ),
                            _buildDashboardButton(
                              "Prescriptions",
                              "assets/Prescription.jpg",
                              "prescriptions",
                            ),
                            _buildDashboardButton(
                              "Ask Me",
                              "assets/Bot.jpg",
                              "askmepage",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: ui.Color.fromARGB(255, 86, 84, 84),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const ui.Color.fromARGB(
                            255,
                            236,
                            232,
                            232,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => _logout(context),
                        child: const Text("Log out"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(String label, String iconPath, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                iconPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'TanjimFonts',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black54,
                ),
              ],
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
