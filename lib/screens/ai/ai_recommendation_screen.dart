import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_theme.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final _moodCtrl = TextEditingController();
  String? _result;
  bool _isLoading = false;
  String _selectedMood = '';

  static const List<Map<String, String>> _moodOptions = [
    {'emoji': '😴', 'label': 'Ngantuk'},
    {'emoji': '😰', 'label': 'Stres'},
    {'emoji': '🎯', 'label': 'Butuh Fokus'},
    {'emoji': '😌', 'label': 'Santai'},
    {'emoji': '💪', 'label': 'Mau Olahraga'},
    {'emoji': '🤒', 'label': 'Kurang Enak Badan'},
  ];

  @override
  void dispose() {
    _moodCtrl.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    final mood = _selectedMood.isNotEmpty ? _selectedMood : _moodCtrl.text.trim();
    if (mood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih atau tulis mood kamu dulu!')));
      return;
    }
    setState(() { _isLoading = true; _result = null; });

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_ANTHROPIC_API_KEY', // ganti dengan key kamu
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content': 'Kamu adalah ahli matcha. Berikan rekomendasi jenis matcha yang cocok untuk seseorang yang sedang merasa "$mood". '
                  'Rekomendasikan 1 jenis matcha (misalnya: matcha latte, ceremonial matcha, iced matcha, matcha smoothie, dll), '
                  'jelaskan alasannya dalam 3-4 kalimat singkat dalam Bahasa Indonesia, '
                  'dan sebutkan berapa gram yang disarankan. Format: langsung ke poin tanpa basa-basi panjang.',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _result = data['content'][0]['text']);
      } else {
        setState(() => _result = 'Gagal mendapat rekomendasi. Coba lagi nanti.');
      }
    } catch (e) {
      setState(() => _result = 'Terjadi kesalahan koneksi. Pastikan internet kamu aktif.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('AI Mood-Based Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.matchaDark, AppTheme.matchaPrimary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  Text('🤖', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text('AI Matcha Advisor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Ceritakan kondisi kamu sekarang,\ndan AI akan rekomendasikan matcha yang cocok!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mood options
            const Text('Pilih Mood Kamu Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: _moodOptions.map((m) {
                final selected = _selectedMood == m['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = selected ? '' : m['label']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.matchaPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppTheme.matchaPrimary : AppTheme.matchaAccent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m['emoji']!, style: const TextStyle(fontSize: 24)),
                        Text(m['label']!, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppTheme.textDark,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom input
            const Text('Atau ceritakan kondisi kamu:', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            const SizedBox(height: 8),
            TextField(
              controller: _moodCtrl,
              decoration: const InputDecoration(hintText: 'Contoh: lagi deadline, butuh konsentrasi tinggi...'),
              onTap: () => setState(() => _selectedMood = ''),
            ),
            const SizedBox(height: 20),

            // Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Dapatkan Rekomendasi 🍵', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            // Result
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.matchaLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.matchaSecondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('🤖', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('Rekomendasi AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.matchaDark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_result!, style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.6)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}