import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslatorHome(),
    );
  }
}

class TranslatorHome extends StatefulWidget {
  @override
  _TranslatorHomeState createState() => _TranslatorHomeState();
}

class _TranslatorHomeState extends State<TranslatorHome> {
  final Map<String, String> _languages = {
    'ar_AR': 'Arabic',
    'cs_CZ': 'Czech',
    'de_DE': 'German',
    'en_XX': 'English',
    'es_XX': 'Spanish',
    'et_EE': 'Estonian',
    'fi_FI': 'Finnish',
    'fr_XX': 'French',
    'gu_IN': 'Gujarati',
    'hi_IN': 'Hindi',
    'it_IT': 'Italian',
    'ja_XX': 'Japanese',
    'kk_KZ': 'Kazakh',
    'ko_KR': 'Korean',
    'lt_LT': 'Lithuanian',
    'lv_LV': 'Latvian',
    'my_MM': 'Burmese',
    'ne_NP': 'Nepali',
    'nl_XX': 'Dutch',
    'ro_RO': 'Romanian',
    'ru_RU': 'Russian',
    'si_LK': 'Sinhala',
    'tr_TR': 'Turkish',
    'vi_VN': 'Vietnamese',
    'zh_CN': 'Chinese',
    'af_ZA': 'Afrikaans',
    'az_AZ': 'Azerbaijani',
    'bn_IN': 'Bengali',
    'fa_IR': 'Persian',
    'he_IL': 'Hebrew',
    'hr_HR': 'Croatian',
    'id_ID': 'Indonesian',
    'ka_GE': 'Georgian',
    'km_KH': 'Khmer',
    'mk_MK': 'Macedonian',
    'ml_IN': 'Malayalam',
    'mn_MN': 'Mongolian',
    'mr_IN': 'Marathi',
    'pl_PL': 'Polish',
    'ps_AF': 'Pashto',
    'pt_XX': 'Portuguese',
    'sv_SE': 'Swedish',
    'sw_KE': 'Swahili',
    'ta_IN': 'Tamil',
    'te_IN': 'Telugu',
    'th_TH': 'Thai',
    'tl_XX': 'Tagalog',
    'uk_UA': 'Ukrainian',
    'ur_PK': 'Urdu',
    'xh_ZA': 'Xhosa',
    'gl_ES': 'Galician',
    'sl_SI': 'Slovene',
  };

  String _selectedSourceLanguage = 'en_XX';
  String _selectedTargetLanguage = 'es_XX';
  bool _showNewTextField = false;

  final TextEditingController _sourceTextController = TextEditingController();
  final TextEditingController _targetTextController = TextEditingController();

  Future<void> _translateText() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': _sourceTextController.text,
        'source_lang': _selectedSourceLanguage,
        'target_lang': _selectedTargetLanguage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _targetTextController.text = data['translated_text'];
        _showNewTextField = true;
      });
    } else {
      throw Exception('Failed to translate text');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trier les langues par ordre alphabétique
    final sortedLanguages = _languages.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C8CE7), Color(0xFF00EAFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    "Language Translator",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Break language barriers instantly",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Translator Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Language Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedSourceLanguage,
                        items: sortedLanguages.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSourceLanguage = value!;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.sync_alt, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            // Échanger les langues source et cible
                            final tempLang = _selectedSourceLanguage;
                            _selectedSourceLanguage = _selectedTargetLanguage;
                            _selectedTargetLanguage = tempLang;

                            // Échanger les textes source et cible
                            final tempText = _sourceTextController.text;
                            _sourceTextController.text = _targetTextController.text;
                            _targetTextController.text = tempText;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        value: _selectedTargetLanguage,
                        items: sortedLanguages.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetLanguage = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Text Input Section
                  TextField(
                    controller: _sourceTextController,
                    decoration: const InputDecoration(
                      hintText: "Enter text to translate...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.mic, color: Colors.lightBlue),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Translate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9A7DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _translateText,
                      child: const Text(
                        "Translate",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // New Text Field
                  if (_showNewTextField)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextField(
                        controller: _targetTextController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: "hello im adam serghini",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Translations Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Translations",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  _RecentTranslationTile(
                    englishText: "Hello, how are you?",
                    translatedText: "¡Hola, ¿cómo estás?",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  Widget _languageTile(String title, String language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.language, color: Colors.lightBlue),
            const SizedBox(width: 5),
            Text(
              language,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

class _RecentTranslationTile extends StatelessWidget {
  final String englishText;
  final String translatedText;

  const _RecentTranslationTile({
    Key? key,
    required this.englishText,
    required this.translatedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          englishText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          translatedText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
