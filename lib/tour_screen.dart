import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'CategoryDetailPage.dart';

class TourPage extends StatefulWidget {
  @override
  _TourPageState createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, List<String>>> _categoryHerbsFuture;

  List<AnimationController> _jiggleControllers = [];
  List<Animation<double>> _jiggleAnimations = [];

  @override
  void initState() {
    super.initState();
    _categoryHerbsFuture = _fetchCategoryHerbs();
  }

  @override
  void dispose() {
    for (var controller in _jiggleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Map<String, List<String>>> _fetchCategoryHerbs() async {
    final categoryHerbs = <String, List<String>>{};
    final snapshot = await _firestore.collection('herbCategories').get();

    for (var doc in snapshot.docs) {
      final category = doc.id;
      final herbs = List<String>.from(doc.data()['herbs'] ?? []);
      categoryHerbs[category] = herbs;
    }
    return categoryHerbs;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gifPaths = [
      'assets/gif1.gif',
      'assets/gif2.gif',
      'assets/gif3.gif',
      'assets/gif4.gif',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text("Herb Plant Categories", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background GIF with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 1.0, // Adjust opacity here (0.0 is fully transparent, 1.0 is fully opaque)
              child: Image.asset(
                'assets/images/tourbackgroundoptimize.gif', // Replace with your GIF file path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content overlay
          FutureBuilder<Map<String, List<String>>>(
            future: _categoryHerbsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories found'));
              }

              final categoryHerbs = snapshot.data!;
              final herbCategories = categoryHerbs.keys.toList();

              // Initialize animations for each circle
              _initializeJiggleAnimations(herbCategories.length);

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: herbCategories.asMap().entries.map((entry) {
                      int index = entry.key;
                      String category = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: AnimatedBuilder(
                          animation: _jiggleAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_jiggleAnimations[index].value, 0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              CategoryDetailPage(
                                                category: category,
                                                herbs: categoryHerbs[category] ?? [],
                                              ),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 70,
                                          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                                          child: ClipOval(
                                            child: Image.asset(
                                              gifPaths[index % gifPaths.length],
                                              fit: BoxFit.cover,
                                              width: 140,
                                              height: 140,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _initializeJiggleAnimations(int count) {
    _jiggleControllers = List.generate(
      count,
          (_) => AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true),
    );

    _jiggleAnimations = _jiggleControllers.map((controller) {
      return Tween<double>(begin: -2.3, end: 2.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }
}
