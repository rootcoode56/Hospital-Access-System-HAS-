import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// ---------------------------
// ENTRY POINT
// ---------------------------
void main() {
  runApp(const HASApp());
}

class HASApp extends StatelessWidget {
  const HASApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C77C3)),
        fontFamily: 'Roboto',
      ),
      home: const DoctorListScreen(),
    );
  }
}

// ---------------------------
// DATA MODEL
// ---------------------------
class Doctor {
  final String name;
  final String title; // e.g., Prof. Dr.
  final String specialty; // brief headline
  final List<String> specialities; // bullets
  final List<String> qualifications; // bullets
  final String institute; // main workplace/hospital
  final String chamberLocation; // hospital name for chamber section
  final String address; // chamber address
  final String visitingHours;
  final String phone;

  Doctor({
    required this.name,
    required this.title,
    required this.specialty,
    required this.specialities,
    required this.qualifications,
    required this.institute,
    required this.chamberLocation,
    required this.address,
    required this.visitingHours,
    required this.phone,
  });

  factory Doctor.fromJson(Map<String, dynamic> m) {
    List<String> _toList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String)
        return v
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      return [];
    }

    return Doctor(
      name: (m['name'] ?? m['Name'] ?? 'Unknown').toString(),
      title: (m['title'] ?? m['Title'] ?? '').toString(),
      specialty: (m['specialty'] ?? m['Specialty'] ?? m['headline'] ?? '')
          .toString(),
      specialities: _toList(
        m['specialities'] ??
            m['Specialities'] ??
            m['Speciality'] ??
            m['SpecialtyList'],
      ),
      qualifications: _toList(
        m['qualifications'] ??
            m['Qualifications'] ??
            m['degree'] ??
            m['Degrees'],
      ),
      institute: (m['institute'] ?? m['Institute'] ?? m['workplace'] ?? '')
          .toString(),
      chamberLocation:
          (m['chamberLocation'] ?? m['ChamberLocation'] ?? m['chamber'] ?? '')
              .toString(),
      address: (m['address'] ?? m['Address'] ?? '').toString(),
      visitingHours:
          (m['visitingHours'] ?? m['VisitingHours'] ?? m['hours'] ?? '')
              .toString(),
      phone: (m['phone'] ?? m['Phone'] ?? m['mobile'] ?? '').toString(),
    );
  }
}

// ---------------------------
// REPOSITORY — LOAD FROM ASSET docs/DocsInfo.json
// ---------------------------
class DoctorRepo {
  static Future<List<Doctor>> load() async {
    final raw = await rootBundle.loadString('assets/DocsInfo.json');
    final data = json.decode(raw);
    if (data is List) {
      return data
          .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map && data['doctors'] is List) {
      return (data['doctors'] as List)
          .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

// ---------------------------
// COMMON — Glass container & pills, background
// ---------------------------
class Frosted extends StatelessWidget {
  const Frosted({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.opacity = .2,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(.3), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PillsLabel extends StatelessWidget {
  const PillsLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Frosted(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        radius: 20,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: const [
              Shadow(
                blurRadius: 4,
                color: Colors.black54,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildBackground() {
  return Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/has_bg.jpg',
        fit: BoxFit.cover,
      ), // Put your background image to match Figma
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xAA0E3A5B), Color(0x660E3A5B)],
          ),
        ),
      ),
    ],
  );
}

// ---------------------------
// LIST SCREEN
// ---------------------------
class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<Doctor> all = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    DoctorRepo.load().then((value) {
      setState(() {
        all = value;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = all.where((d) {
      final q = query.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const PillsLabel('All Doctors are Here'),
                  const SizedBox(height: 18),
                  Frosted(
                    radius: 28,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => query = v),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter Doctor Name',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, i) {
                              final d = filtered[i];
                              return Hero(
                                tag: d.name,
                                child: Frosted(
                                  child: InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 450,
                                        ),
                                        pageBuilder: (_, a1, a2) =>
                                            FadeTransition(
                                              opacity: a1,
                                              child: DoctorDetailScreen(
                                                doctor: d,
                                              ),
                                            ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (d.specialty.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            d.specialty,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        if (d.qualifications.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          _Bullets(
                                            d.qualifications.take(3).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Frosted(
                      radius: 26,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// DETAIL SCREEN
// ---------------------------
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const PillsLabel('Doctor Info'),
                  const SizedBox(height: 14),
                  Hero(
                    tag: doctor.name,
                    child: Frosted(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.title.isNotEmpty
                                ? '${doctor.title} ${doctor.name}'
                                : doctor.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _SectionTitle('Specialist'),
                          Text(
                            doctor.specialty.isNotEmpty
                                ? '${doctor.specialty}\n${doctor.institute.isNotEmpty ? doctor.institute : ''}'
                                : doctor.institute,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _SectionTitle('Speciality'),
                          if (doctor.specialities.isNotEmpty)
                            _Bullets(doctor.specialities)
                          else if (doctor.qualifications.isNotEmpty)
                            _Bullets(doctor.qualifications),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Frosted(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Chamber Location'),
                        if (doctor.chamberLocation.isNotEmpty)
                          Text(
                            doctor.chamberLocation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (doctor.address.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            doctor.address,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ],
                        if (doctor.visitingHours.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Visiting Hours: ${doctor.visitingHours}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                        if (doctor.phone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Phone: ${doctor.phone}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Frosted(
                        radius: 30,
                        padding: const EdgeInsets.all(12),
                        child: IconButton(
                          onPressed: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                          icon: const Icon(Icons.home, color: Colors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Frosted(
                          radius: 26,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(color: Colors.white, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
