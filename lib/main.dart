import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traducteur',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const TranslatorPage(),
    );
  }
}

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  bool _isLoading = false;
  String _sourceLang = 'fr_XX';
  String _targetLang = 'en_XX';

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
  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _sourceController.text,
          'source_lang': _sourceLang,
          'target_lang': _targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _targetController.text = data['translated_text'];
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur de traduction');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traducteur'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sourceLang,
                    isExpanded: true,
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _sourceLang = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _sourceLang;
                      _sourceLang = _targetLang;
                      _targetLang = temp;
                      final tempText = _sourceController.text;
                      _sourceController.text = _targetController.text;
                      _targetController.text = tempText;
                    });
                  },
                ).animate().scale(duration: const Duration(milliseconds: 200)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _targetLang,
                    isExpanded: true,
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _targetLang = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Entrez le texte à traduire',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _translate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(_isLoading ? 'Traduction en cours...' : 'Traduire'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            )
                .animate()
                .scale(duration: const Duration(milliseconds: 200))
                .then()
                .shimmer(duration: const Duration(milliseconds: 800)),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              maxLines: 5,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Traduction',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
