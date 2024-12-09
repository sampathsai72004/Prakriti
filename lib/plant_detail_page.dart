import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:translator/translator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'plant_3d_view_page.dart';
import 'chatbot_home.dart';

class PlantDetailPage extends StatefulWidget {
  final String herbName;

  const PlantDetailPage({
    super.key,
    required this.herbName,
  });

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final translator = GoogleTranslator();

  Map<String, dynamic>? plantData;
  Map<String, dynamic>? originalPlantData;
  bool isLoading = true;

  String selectedLanguage = 'en';
  final Map<String, String> languageMap = {
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Kannada': 'kn',
    'Telugu':'te',
  };

  List<QueryDocumentSnapshot>? treatments;
  Map<String, bool> expandedState = {}; // Tracks expanded state for treatments
  bool isLoadingTreatments = true;

  @override
  void initState() {
    super.initState();
    fetchPlantDetails();
  }

  Future<void> fetchPlantDetails() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('plantDetails')
          .doc(widget.herbName)
          .get();

      if (snapshot.exists) {
        setState(() {
          originalPlantData = snapshot.data() as Map<String, dynamic>;
          plantData = Map<String, dynamic>.from(originalPlantData!);
          isLoading = false;
        });
        fetchTreatments();
      } else {
        setState(() {
          isLoading = false;
        });
        print("No data found for herbName: ${widget.herbName}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching plant details: $e");
    }
  }

  Future<void> fetchTreatments() async {
    try {
      final snapshot = await _firestore
          .collection('plantDetails')
          .doc(widget.herbName)
          .collection('treatments')
          .get();

      setState(() {
        treatments = snapshot.docs;
        isLoadingTreatments = false;
        for (var treatment in treatments!) {
          expandedState[treatment.id] = false;
        }
      });
    } catch (e) {
      print('Error fetching treatments: $e');
      setState(() {
        isLoadingTreatments = false;
      });
    }
  }

  Future<String> translateText(String text, String targetLang) async {
    try {
      const placeholder = '\n';
      final preprocessedText = text.replaceAll('trigger', placeholder);

      if (targetLang == 'en') {
        return preprocessedText.replaceAll(placeholder, 'trigger');
      }

      final translated = await translator.translate(preprocessedText, to: targetLang);

      return translated.text.replaceAll(placeholder, 'trigger');
    } catch (e) {
      print("Translation error: $e");
      return text; // Return original text if translation fails
    }
  }

  List<String> processText(String text) {
    return text.split('trigger').map((line) => line.trim()).toList();
  }

  Future<void> translateData() async {
    if (originalPlantData == null || selectedLanguage == 'en') {
      setState(() {
        plantData = Map<String, dynamic>.from(originalPlantData!);
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    plantData = {
      for (var entry in originalPlantData!.entries)
        entry.key: entry.value is String
            ? await translateText(entry.value as String, selectedLanguage)
            : entry.value is List<String>
            ? await translateList(entry.value as List<String>, selectedLanguage)
            : entry.value,
    };

    setState(() {
      isLoading = false;
    });
  }

  Future<List<String>> translateList(List<String> texts, String targetLang) async {
    return Future.wait(texts.map((text) => translateText(text, targetLang)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (plantData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No details available for ${widget.herbName}.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final images = List<String>.from(plantData!['images'] ?? []);
    final leafInfo =
    processText(plantData!['leafInfo'] ?? 'No leaf information available');
    final rootInfo =
    processText(plantData!['rootInfo'] ?? 'No root information available');
    final stemInfo =
    processText(plantData!['stemInfo'] ?? 'No stem information available');
    final advantages = processText(
        plantData!['advantages'] ?? 'No advantages information available');
    final disadvantages = processText(plantData!['disadvantages'] ??
        'No disadvantages information available');
    final medicinalUses = processText(plantData!['medicinalUses'] ??
        'No medicinal uses information available');
    final growCultivate = processText(
        plantData!['growCultivate'] ?? 'No cultivation information available');
    final medicinalVideos =
    List<String>.from(plantData!['medicinalVideos'] ?? []);

    // Dropdown for language selection
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.herbName, style: const TextStyle(color: Color(0xFFF39C12) )),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            icon: const Icon(Icons.language, color: Color(0xFFF39C12)),
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
                isLoading = true;
              });
              translateData();
            },
            items: languageMap.keys.map<DropdownMenuItem<String>>((String lang) {
              return DropdownMenuItem<String>(
                value: languageMap[lang]!,
                child: Text(lang, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.threed_rotation, color: Color(0xFFF39C12)),
            onPressed: () {
              // Navigate to 3D view page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Plant3DViewPage(
                    herbName: widget.herbName,
                    modelPath: 'assets/${widget.herbName.toLowerCase()}/model.obj',
                    mtlPath: 'assets/${widget.herbName.toLowerCase()}/model.mtl',
                    pngPath: 'assets/${widget.herbName.toLowerCase()}/texture.png',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index, realIndex) {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                  child: Text('Image not available')),
                            );
                          },
                        );
                      },
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                )
              else
                Container(
                  height: 200.0,
                  color: Colors.grey,
                  child: const Center(child: Text('No images available')),
                ),
              const SizedBox(height: 16.0),
              _buildSection('Latin Name',
                  plantData!['latinName'] ?? 'No Latin name available'),
              const SizedBox(height: 16.0),
              _buildSectionWithImage(
                  'Leaves', leafInfo, images.isNotEmpty ? images[0] : null),
              const SizedBox(height: 16.0),
              _buildSectionWithImage(
                  'Roots', rootInfo, images.length > 1 ? images[1] : null),
              const SizedBox(height: 16.0),
              _buildSectionWithImage(
                  'Stem', stemInfo, images.length > 2 ? images[2] : null),
              const SizedBox(height: 16.0),
              _buildTextSection('Advantages', advantages),
              const SizedBox(height: 16.0),
              _buildTextSection('Disadvantages', disadvantages),
              const SizedBox(height: 16.0),
              _buildTextSection('Medicinal Uses', medicinalUses),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Treatments',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFF39C12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              if (isLoadingTreatments)
                const Center(child: CircularProgressIndicator())
              else if (treatments == null || treatments!.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No treatments available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: treatments!.length,
                  itemBuilder: (context, index) {
                    final treatment = treatments![index];
                    final treatmentName = treatment.id;
                    final dosage = treatment['dosage'] ?? 'No dosage available';
                    final daytouse = treatment['daytouse'] ?? 'No daytouse available';

                    final precautions = treatment['precautions'] ?? 'No precautions available';
                    final symptoms = treatment['symptons'] ?? 'No symptoms available';
                    final isExpanded = expandedState[treatmentName] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedState[treatmentName] = !isExpanded;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    treatmentName,
                                    style: const TextStyle(
                                      color: Color(0xFF99CEFF),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8.0),
                            Text('Dosage', style: const TextStyle(color: Color(
                                0xFFFF7E7E))),
                            Text('$dosage', style: const TextStyle(color: Colors.white)),
                            Text('Precautions', style: const TextStyle(color: Color(
                                0xFFFF7E7E))),
                            Text('$precautions', style: const TextStyle(color: Colors.white)),
                            Text('Symptoms', style: const TextStyle(color: Color(
                                0xFFFF7E7E))),
                            Text('$symptoms', style: const TextStyle(color: Colors.white)),
                            Text('Number of Days to use:',
                                style: const TextStyle(color: Color(
                                    0xFFFF7E7E))),
                            Text('$daytouse', style: const TextStyle(color: Colors.white)),
                          ],
                          const SizedBox(height: 8.0),
                          Divider(
                            color: Colors.white.withOpacity(0.6), // White color with 60% opacity
                            thickness: 0.5, // Minimal thickness
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16.0),
              _buildTextSection('How to Grow / Cultivate', growCultivate),
              const SizedBox(height: 16.0),
              if (medicinalVideos.isNotEmpty)
                _buildVideosSection(medicinalVideos),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBotScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 255, 234, 199), // Button color
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                  ),
                  child: const Text(
                    'For more information ask our Herbi Bot',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for creating sections with a title and text
  Widget _buildSection(String label, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Helper method for creating sections with images and text
  Widget _buildSectionWithImage(
      String label, List<String> info, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            height: 150,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              print('Failed to load image: $url');
              return Container(
                height: 150,
                color: Colors.grey,
                child: const Center(child: Text('Image not available')),
              );
            },
          ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info
              .map(
                (text) => Text(
              text,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  // Helper method for creating text-only sections
  Widget _buildTextSection(String label, List<String> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: info
              .map(
                (text) => Text(
              text,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  // Helper method for embedding videos
  Widget _buildVideosSection(List<String> videoUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicinal Videos',
          style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFFF39C12),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Column(
          children: videoUrls.map((videoUrl) {
            final videoId = YoutubePlayer.convertUrlToId(videoUrl);
            if (videoId == null) {
              print("Invalid video URL: $videoUrl");
              return const Text('Invalid video URL');
            }
            return YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: false,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
            );
          }).toList(),
        ),
      ],
    );
  }
}