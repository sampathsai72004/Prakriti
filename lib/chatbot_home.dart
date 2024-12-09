import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _HomePageState();
}

class _HomePageState extends State<ChatBotScreen> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Herbi",
    profileImage:
        "herbi.png",
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Herbi Bot",
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        // Background GIF with opacity
        Opacity(
          opacity: 0.15, // Set opacity for the GIF
          child: SizedBox.expand(
            child: Image.asset(
              'assets/images/appbackgroundoptimize.gif', // Path to your GIF file
              fit: BoxFit.cover, // Fill the screen
            ),
          ),
        ),

        // Chat UI
        DashChat(
          inputOptions: InputOptions(trailing: [
            IconButton(
              onPressed: _sendMediaMessage,
              icon: const Icon(Icons.image),
            ),
          ]),
          currentUser: currentUser,
          onSend: _sendMessage,
          messages: messages,
        ),
      ],
    );
  }


  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    String question = chatMessage.text.toLowerCase();

    // Append the context for Ayurvedic or herbal topics
    String herbalContext = "";

    // Check if the question contains the word 'suffering'
    if (question.contains("suffering")) {
      herbalContext =
          "treatment in ayurvedic"; // Change context to treatment if 'suffering' is mentioned
    }

    String formattedQuestion =
        "$question $herbalContext"; // Debugging line to check the result

    // List of keywords related to herbal plants
    List<String> herbalKeywords = [
      // Herbal Plants

      "Aloe Vera",
      "aloevera"
          "ashwagandha",
      "tulsi (Holy Basil)",
      "neem",
      "turmeric (Haldi)",
      "brahmi",
      "gotu Kola",
      "shatavari",
      "giloy",
      "amla (Indian Gooseberry)",
      "arjuna",
      "moringa",
      "bhringraj",
      "shikakai",
      "fenugreek (Methi)",
      "ginger (Adrak)",
      "garlic (Lasun)",
      "mint (Pudina)",
      "cardamom (Elaichi)",
      "cinnamon (Dalchini)",
      "cloves (Laung)",
      "peppermint",
      "sandalwood",
      "vetiver",
      "curry Leaves (Kadi Patta)",
      "essential oils",
      "natural medicine",
      "healing",
      "organic",
      // General herbal terms
      "herb",
      "alovera",
      "herbal",
      "plant",
      "medicinal",
      "natural remedy",
      "natural medicine",
      "healing",
      "essential oils",
      "leaves",
      "roots",
      "flowers",
      "bark",
      "seeds",
      "aromatic",
      "in the context of ayurvedic or herbal medicine",
      "organic",
      "phytotherapy",
      "in context",
      "in the context of ayurvedic",
      "botanical",
      "traditional healing",
      "natural products",
      "folk medicine",
      "eco-friendly",

      // Ayurvedic and Indian herbal terms
      "ayurveda",
      "ayurvedic",
      "indian herbs",
      "siddha",
      "unani",
      "holistic healing",
      "ancient medicine",
      "traditional medicine",
      "ayurvedic remedies",
      "dosha",
      "kapha",
      "pitta",
      "vata",
      "chakras",
      "prana",
      "nadi",
      "herbal supplements",
      "herbal oils",

      // Specific herbs (global and Indian)
      "aloe vera",
      "tulsi",
      "holy basil",
      "neem",
      "turmeric",
      "haldi",
      "ashwagandha",
      "brahmi",
      "gotu kola",
      "shatavari",
      "giloy",
      "amla",
      "indian gooseberry",
      "arjuna",
      "moringa",
      "drumstick leaves",
      "vetiver",
      "curry leaves",
      "pudina",
      "mint",
      "lemongrass",
      "saffron",
      "kesar",
      "kasturi",
      "hibiscus",
      "shikakai",
      "bhringraj",
      "fenugreek",
      "methi",
      "cardamom",
      "elaichi",
      "cinnamon",
      "dalchini",
      "cloves",
      "laung",
      "peppermint",
      "ginger",
      "adrak",
      "garlic",
      "lasun",
      "black pepper",
      "kali mirch",
      "nutmeg",
      "javitri",
      "kalonji",
      "nigella seeds",
      "black seed oil",
      "kokum",
      "jatamansi",
      "sandalwood",
      "rose water",
      "aloevera gel",
      "coriander",
      "dhania",
      "cumin",
      "jeera",
      "fennel",
      "saunf",
      "oregano",
      "thyme",
      "bay leaf",
      "tej patta",
      "mustard seeds",
      "rai",
      "tamarind",
      "imli",

      // Herbal teas and infusions
      "herbal tea",
      "treatment in ayurvedic",
      "green tea",
      "tulsi tea",
      "ginger tea",
      "chamomile",
      "peppermint tea",
      "hibiscus tea",
      "lemongrass tea",
      "detox tea",
      "digestive tea",

      // Diseases and conditions treated by herbs
      "immunity booster",
      "cold remedy",
      "cough remedy",
      "fever remedy",
      "digestion",
      "indigestion",
      "constipation",
      "diarrhea",
      "skin treatment",
      "acne remedy",
      "eczema",
      "psoriasis",
      "anti-aging",
      "hair growth",
      "hair fall",
      "dandruff",
      "stress relief",
      "anxiety",
      "depression",
      "sleep disorder",
      "insomnia",
      "weight loss",
      "detox",
      "antioxidant",
      "anti-inflammatory",
      "arthritis",
      "joint pain",
      "cholesterol",
      "high blood pressure",
      "diabetes",
      "liver health",
      "kidney health",
      "urinary tract infection",
      "UTI",
      "respiratory health",
      "bronchitis",
      "asthma",
      "boost energy",
      "mental clarity",
      "memory booster",
      "cancer prevention",
      "eye health",
      "vision improvement",

      // Herbal skincare and beauty
      "skincare",
      "face mask",
      "herbal face pack",
      "herbal shampoo",
      "hair oil",
      "coconut oil",
      "almond oil",
      "castor oil",
      "rose oil",
      "argan oil",
      "skin brightening",
      "blemishes",
      "wrinkles",
      "dark spots",
      "glowing skin",

      // Herbal food and drinks
      "herbal soup",
      "herbal juice",
      "smoothies",
      "aloe vera juice",
      "amla juice",
      "tulsi drops",
      "neem juice",
      "herbal capsules",
      "herbal powder",
      "ayurvedic powders",
      "churna",
      "kadha",
      "herbal decoction",

      // Miscellaneous related terms
      "natural treatment",
      "holistic medicine",
      "organic remedies",
      "health benefits",
      "remedy for cold",
      "remedy for cough",
      "ayurvedic medicine",
      "herbal remedies",
      "ancient remedies",
      "tribal medicine",
      "herbal farming",
      "homeopathy",
    ];

    // Check if the question contains any herbal-related keywords
    bool isHerbalRelated =
        herbalKeywords.any((keyword) => formattedQuestion.contains(keyword));

    if (!isHerbalRelated) {
      // Respond with a predefined message for unrelated queries
      ChatMessage unrelatedMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text:
            "I can only answer questions about herbal plants. Please ask something herbal-related.",
      );

      setState(() {
        messages = [unrelatedMessage, ...messages];
      });
      return; // Stop further processing for unrelated queries
    }

    // Process herbal-related queries with the Gemini API
    try {
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
