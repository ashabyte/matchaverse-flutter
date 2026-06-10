import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchPosts(refresh: true);
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<CommunityProvider>().fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Komunitas Matcha Lovers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost),
        backgroundColor: AppTheme.matchaPrimary,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Bagikan', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, community, _) {
          return RefreshIndicator(
            onRefresh: () => community.fetchPosts(refresh: true),
            child: community.posts.isEmpty && community.isLoading
                ? const Center(child: CircularProgressIndicator())
                : community.posts.isEmpty
                    ? const Center(child: Text('Belum ada postingan. Jadilah yang pertama! 🍵'))
                    : ListView.separated(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: community.posts.length + (community.isLoading ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          if (i == community.posts.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          final post = community.posts[i];
                          return _PostCard(post: post);
                        },
                      ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final dynamic post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: post.userPhoto.isNotEmpty ? NetworkImage(post.userPhoto) : null,
                backgroundColor: AppTheme.matchaAccent,
                child: post.userPhoto.isEmpty ? const Text('🍵') : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    Text(
                      _timeAgo(post.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              Consumer<AuthProvider>(
                builder: (ctx, auth, _) {
                  if (auth.user?.uid != post.userId) return const SizedBox();
                  return IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => ctx.read<CommunityProvider>().deletePost(post.id, auth.authToken!),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(post.content, style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.5)),
          // Tags
          if ((post.tags as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: (post.tags as List).map<Widget>((tag) => Chip(
                label: Text('#$tag', style: const TextStyle(fontSize: 11, color: AppTheme.matchaPrimary)),
                backgroundColor: AppTheme.matchaLight,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Consumer<AuthProvider>(
                builder: (ctx, auth, _) => GestureDetector(
                  onTap: auth.user != null
                      ? () => ctx.read<CommunityProvider>().likePost(post.id, auth.user!.uid, auth.authToken!)
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        color: post.isLikedByMe ? Colors.red : AppTheme.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likes}', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline, size: 20, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Text('${post.comments}', style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}