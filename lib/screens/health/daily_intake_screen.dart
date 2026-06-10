import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/intake_record.dart';
import '../../providers/health_tracker_provider.dart';
import '../../providers/auth_provider.dart';

class DailyIntakeScreen extends StatefulWidget {
  const DailyIntakeScreen({super.key});

  @override
  State<DailyIntakeScreen> createState() => _DailyIntakeScreenState();
}

class _DailyIntakeScreenState extends State<DailyIntakeScreen> {
  final _gramsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedType = 'Matcha Latte';
  bool _isLoading = false;

  static const List<String> _matchaTypes = [
    'Matcha Latte', 'Matcha Shot', 'Ceremonial Matcha',
    'Matcha Smoothie', 'Matcha Baking', 'Matcha Mochi',
    'Iced Matcha', 'Matcha Tiramisu',
  ];

  double get _estimatedCaffeine {
    final grams = double.tryParse(_gramsCtrl.text) ?? 0;
    return grams * 35;
  }

  @override
  void dispose() {
    _gramsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Catat Konsumsi Matcha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.matchaLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.matchaAccent),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rata-rata 1g matcha = 35mg kafein.\nBatas aman harian: 400mg (±11g matcha).',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMedium, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Jenis Matcha
            const Text('Jenis Matcha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _matchaTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: const InputDecoration(hintText: 'Pilih jenis matcha'),
            ),
            const SizedBox(height: 16),

            // Gram
            const Text('Jumlah (gram)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _gramsCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Contoh: 2.5',
                suffixText: 'gram',
              ),
            ),
            const SizedBox(height: 8),

            // Estimasi kafein
            if (_gramsCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _estimatedCaffeine > 200
                      ? Colors.orange.shade50
                      : AppTheme.matchaLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _estimatedCaffeine > 200 ? Colors.orange : AppTheme.matchaAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _estimatedCaffeine > 200 ? '⚠️' : '☕',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi kafein: ${_estimatedCaffeine.toStringAsFixed(0)}mg',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _estimatedCaffeine > 200 ? Colors.orange.shade700 : AppTheme.matchaPrimary,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Catatan
            const Text('Catatan (opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Contoh: matcha pagi dari Kafe XYZ, rasanya enak!'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Simpan Konsumsi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_gramsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jumlah gram terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final tracker = context.read<HealthTrackerProvider>();

    final record = IntakeRecord(
      id: '',
      userId: auth.user!.uid,
      matchaType: _selectedType,
      gramsConsumed: double.parse(_gramsCtrl.text),
      caffeineAmount: _estimatedCaffeine,
      notes: _notesCtrl.text,
      consumedAt: DateTime.now(),
    );

    final ok = await tracker.addIntakeRecord(record, auth.authToken!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Konsumsi berhasil dicatat!'),
          backgroundColor: AppTheme.matchaPrimary,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan, coba lagi'), backgroundColor: Colors.red),
      );
    }
  }
}