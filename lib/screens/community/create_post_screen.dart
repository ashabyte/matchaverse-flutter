import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/community_post.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() { _tags.add(tag); _tagCtrl.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Bagikan Perjalanan Matcha'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (ctx, auth, _) => Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: auth.user?.photoURL != null ? NetworkImage(auth.user!.photoURL!) : null,
                    backgroundColor: AppTheme.matchaAccent,
                    child: auth.user?.photoURL == null ? const Text('🍵') : null,
                  ),
                  const SizedBox(width: 10),
                  Text(auth.user?.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Ceritakan pengalaman matcha kamu hari ini... ☕\n\nContoh: Baru coba matcha dari Uji, Jepang. Rasanya earthy banget dan warnanya hijau terang!',
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Tag', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(hintText: 'Tambah tag (contoh: matchalatte)'),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTag, child: const Text('+')),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _tags.map((tag) => Chip(
                  label: Text('#$tag'),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                  backgroundColor: AppTheme.matchaLight,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tulis sesuatu dulu!')));
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final post = CommunityPost(
      id: '', userId: auth.user!.uid, userName: auth.user!.displayName ?? '',
      userPhoto: auth.user!.photoURL ?? '', content: _contentCtrl.text.trim(),
      likes: 0, comments: 0, isLikedByMe: false, tags: _tags, createdAt: DateTime.now(),
    );
    final ok = await context.read<CommunityProvider>().createPost(post, auth.authToken!);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Postingan berhasil dibuat!'), backgroundColor: AppTheme.matchaPrimary),
      );
    }
  }
}