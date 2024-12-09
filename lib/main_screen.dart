import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Import your screens
import 'home_screen.dart';
import 'ChatScreen.dart';
import 'search_screen.dart';
import 'chatbot_home.dart';
import 'tour_screen.dart';
import 'ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Track listening state
  String _command = ""; // Store spoken command

  Offset _buttonPosition = const Offset(300, 600); // Initial button position
  bool _isMicTapped = false; // Track whether the mic button is tapped

  final List<Widget> _pages = [
    HomePage(),
    ChatScreen(),
    SearchPage(),
    ChatBotScreen(),
    TourPage(),
    ProfilePage(),
  ];

  // Mapping voice commands to pages
  final Map<String, int> _voiceCommands = {
    "home": 0,
    "favourite": 1,
    "search": 2,
    "chatbot": 3,
    "tour": 4,
    "profile": 5,
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Handle item tap (manual navigation)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Start listening for voice commands
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      print("Speech-to-Text initialized: $available");

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          print("Recognized words: ${result.recognizedWords}");
          setState(() {
            _command = result.recognizedWords.toLowerCase();
            _navigateByVoiceCommand(_command);
          });
        });
      } else {
        print("Speech recognition not available.");
      }
    }
  }

  // Stop listening
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  // Navigate based on voice command
  void _navigateByVoiceCommand(String command) {
    if (_voiceCommands.containsKey(command)) {
      setState(() {
        _selectedIndex = _voiceCommands[command]!; // Update navigation
        _stopListening(); // Stop listening after navigation
      });
    } else {
      print("Command not recognized: $command");
    }
  }

  // Ensure the button stays within screen boundaries and above the navigation bar
  Offset _restrictButtonPosition(Offset position) {
    double maxX = MediaQuery.of(context).size.width - 200; // Max X position (button width)
    double maxY = MediaQuery.of(context).size.height - 100 - kBottomNavigationBarHeight; // Max Y position (button height) considering the navigation bar height
    double minX = 0;
    double minY = 0;

    // Restrict button within the screen limits
    double newX = position.dx.clamp(minX, maxX);
    double newY = position.dy.clamp(minY, maxY);

    return Offset(newX, newY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex], // Show the current page
          Positioned(
            top: _buttonPosition.dy,
            left: _buttonPosition.dx,
            child: Draggable(
              feedback: _buildMicButton(), // Display button without opacity or blur effect
              child: _buildMicButton(),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                // Restrict button position within screen bounds
                setState(() {
                  _buttonPosition = _restrictButtonPosition(details.offset);
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0x00ffffff),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: 'Tour',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,

        onTap: _onItemTapped,
      ),
    );
  }

  // Build the mic button with text
  Widget _buildMicButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the tapped state on each tap
          _isMicTapped = !_isMicTapped;
        });
        if (_isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
      child: Container(
        width: 150, // Width of the button
        height: 50, // Height of the button
        decoration: BoxDecoration(
          color: _isMicTapped ? Colors.transparent : Colors.grey, // Toggle between gray and transparent
          borderRadius: BorderRadius.circular(25), // Curved corners
          border: Border.all(
            color: Colors.lightBlue,  // Border color (white, change as needed)
            width: 2,  // Border width
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25), // Clip the GIF to match the border's curvature
          child: Stack(
            children: [
              // Background GIF, only show after button is tapped
              if (_isMicTapped)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/appbackgroundoptimize.gif',  // Replace with your GIF path
                    fit: BoxFit.cover,  // Cover the entire button
                  ),
                ),
              // Content of the button (Icon and Text)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row
                  children: [
                    Icon(
                      Icons.mic,
                      color: _isMicTapped ? Colors.white : Colors.black, // White icon when tapped
                    ),
                    const SizedBox(width: 8), // Spacing between icon and text
                    Text(
                      "Vocal Assistant", // Text beside the icon
                      style: TextStyle(
                        color: _isMicTapped ? Colors.white : Colors.black, // White text when tapped
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
