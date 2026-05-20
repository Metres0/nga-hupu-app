import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../parser/bbcode.dart';
import '../models/models.dart';
import 'glass_card.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final int depth;
  final Post? replyTarget;
  final bool isOP;

  const PostCard({
    super.key,
    required this.post,
    this.depth = 0,
    this.replyTarget,
    this.isOP = false,
  });

  static const _depthColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _depthColors[depth.clamp(0, 4)];
    final isNested = depth > 0;

    return Padding(
      padding: EdgeInsets.only(left: isNested ? 16.0 * depth : 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: isNested
            ? BoxDecoration(
                border: Border(left: BorderSide(color: color.withValues(alpha: 0.3), width: 2)),
              )
            : (isOP
                ? BoxDecoration(
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null),
        child: GlassCard(
          padding: EdgeInsets.all(isNested ? 10 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: isNested ? 10 : 12,
                    backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.3),
                    child: Text(
                      post.author.isNotEmpty ? post.author[0] : '?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isNested ? 10 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.author,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: isNested ? 12 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (post.replyTo != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '#${post.replyTo}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '#${post.floor}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reply preview
              if (replyTarget != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Text(
                    replyTarget!.content.length > 100
                        ? '${replyTarget!.content.substring(0, 100)}...'
                        : replyTarget!.content,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Content
              if (post.contentHtml.isNotEmpty)
                _buildHtmlContent(context, post.contentHtml)
              else
                Text(
                  post.content.isEmpty ? '(无内容)' : post.content,
                  style: TextStyle(
                    color: post.content.isEmpty
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: isNested ? 13 : 14,
                    height: 1.6,
                  ),
                ),

              // Images
              if (post.images.isNotEmpty) ...[
                const SizedBox(height: 10),
                ImageGallery(images: post.images),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHtmlContent(BuildContext context, String html) {
    // Parse BBCode first, then render as HTML with image proxy
    final parsed = bbcodeToHtml(html);
    return Container(
      width: double.infinity,
      child: _BbcodeText(html: parsed),
    );
  }
}

/// Minimal BBCode HTML renderer using TextSpan
class _BbcodeText extends StatelessWidget {
  final String html;
  const _BbcodeText({required this.html});

  @override
  Widget build(BuildContext context) {
    return Text(
      html.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.82),
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  final List<String> images;
  const ImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: images.take(6).map((url) {
        final proxyUrl = url.startsWith('http') ? '/api/v1/image-proxy?url=${Uri.encodeComponent(url)}' : url;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: proxyUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24, size: 48),
                      ),
                    ),
                    Positioned(
                      top: 48,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: proxyUrl,
              width: (MediaQuery.of(context).size.width - 48) / 3,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.white.withValues(alpha: 0.05),
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.white.withValues(alpha: 0.05),
                child: const Icon(Icons.broken_image, color: Colors.white24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
