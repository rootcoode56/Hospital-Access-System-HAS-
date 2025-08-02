import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:has/main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> announcements = [
    "Welcome to HAS!",
    "Free health checkup on Friday",
    "New specialist doctors added!",
    "24/7 Emergency Services Available",
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < announcements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
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
    final user = FirebaseAuth.instance.currentUser;

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

                // Announcement slideshow
                SizedBox(
                  height: 40,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      return Center(
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
                              child: Text(
                                announcements[index],
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
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Top section: User avatar above name aligned right, HAS logo centered below
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
                            // Avatar Circle
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/account'),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                backgroundImage: user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : const AssetImage(
                                            'assets/default_avatar.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // User Name
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/account'),
                              child: Text(
                                user?.displayName ?? "User",
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
                          ],
                        ),
                      ),

                      // Centered HAS Logo below user info
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
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
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Glassy box with 6 buttons
                SizedBox(
                  height: 550,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(25),
                    ),
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
                          "ask",
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom row: Settings & Logout
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
