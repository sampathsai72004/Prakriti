import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'plant_detail_page.dart';
import 'chatbot_home.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isRetrieving = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();
  }

  Future<void> _fetchAllPlants() async {
    setState(() {
      _isRetrieving = true;
    });

    try {
      final snapshotPlantDetails = await _firestore.collection('plantDetails').get();
      final snapshotHealthcare = await _firestore.collection('healthcare').get();

      setState(() {
        // Fetch data from 'plantDetails'
        final plantDetails = snapshotPlantDetails.docs.map((doc) {
          final advantages = doc.data()['advantages'] as String? ?? '';
          final disadvantages = doc.data()['disadvantages'] as String? ?? '';
          final leaves = doc.data()['leafInfo'] as String? ?? '';
          final stems = doc.data()['stemInfo'] as String? ?? '';
          final latin = doc.data()['latinName'] as String? ?? '';
          return {
            'name': doc.id,
            'details': '$advantages $disadvantages $leaves $stems $latin',
          };
        }).toList();

        // Fetch data from 'healthcare'
        final healthcareDetails = snapshotHealthcare.docs.map((doc) {
          final List<dynamic> treat = doc.data()['treat'] as List<dynamic>? ?? [];
          return {
            'name': doc.id,
            'details': treat.join(', '),
          };
        }).toList();

        // Combine both collections
        _allPlants = [...plantDetails, ...healthcareDetails];
        _searchResults = _allPlants;
        _isRetrieving = false;
      });
    } catch (e) {
      print("Error fetching plants: $e");
      setState(() {
        _isRetrieving = false;
      });
    }
  }

  void _searchPlants(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          _searchResults = _allPlants;
        } else {
          _searchResults = _allPlants
              .where((plant) =>
          plant['name']!.toLowerCase().contains(query.toLowerCase()) ||
              plant['details']!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        _isSearching = false;
      });
    });
  }

  String _getImageForHerb(String herbName) {
    // Check herbName and return the appropriate image path
    switch (herbName.toLowerCase()) {
      case 'aloe vera':
        return 'assets/images/aloe_vera.png';  // Example image path
      case 'basil':
        return 'assets/images/basil.png';  // Example image path
      case 'turmeric':
        return 'assets/images/turmeric.png';
      case 'amla':
        return 'assets/images/amla.png';   // Example image path
      case 'brahmi':
        return 'assets/images/brahmi.png';
      case 'cardamom':
        return 'assets/images/cardamom.png';
      case 'eucalyptus':
        return 'assets/images/eucalyptus.png';
      case 'henna':
        return 'assets/images/henna.png';
      case 'licorice':
        return 'assets/images/licorice.png';
      case 'mullein':
        return 'assets/images/mullein.png';
      case 'neem':
        return 'assets/images/neem.png';
      case 'peppermint':
        return 'assets/images/peppermint.png';
      case 'thyme':
        return 'assets/images/thyme.png';
      case 'tulasi':
        return 'assets/images/tulasi.png';
      case 'alovera':
        return 'assets/images/aloe_vera.png';
      case 'triphala':
        return 'assets/images/triphala.png';

      case 'coconut':
        return 'assets/images/coconut.png';
      case 'ashawaganda':
        return 'assets/images/ashawaganda.png';
      case 'ginger':
        return 'assets/images/ginger.png';
    // Add more cases as needed for other herbs
      default:
        return 'assets/images/default_herb.png';  // Default image if herb name doesn't match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Plants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // Set black background
        child: Stack(
          children: [
            // Background image with a black overlay
            Positioned.fill(
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.15, // Set opacity for the GIF
                    child: SizedBox.expand(
                      child: Image.asset(
                        'assets/images/appbackgroundoptimize.gif', // Path to your GIF file
                        fit: BoxFit.cover, // Fill the screen
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.15), // Semi-transparent overlay
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: _searchPlants,
                    decoration: InputDecoration(
                      hintText: 'Search for a plant or disease .....',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: _isSearching
                          ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      )
                          : null,
                    ),
                    style: TextStyle(color: Colors.black),
                    cursorColor: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _isRetrieving
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                      : _searchResults.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No matching plants found.',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the chatbot page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatBotScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text('Ask the Chatbot'),
                        ),
                      ],
                    ),
                  )
                      : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    color: Color(0x33727272),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical:3.0, horizontal: 16.0),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                          _getImageForHerb(_searchResults[index]['name']!),
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      title: Text(
                                        _searchResults[index]['name']!,
                                        style: TextStyle(fontSize: 20, color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        _searchResults[index]['details']!,
                                        style: TextStyle(color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlantDetailPage(
                                              herbName: _searchResults[index]['name']!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
