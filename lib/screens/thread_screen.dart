import 'package:flutter/material.dart';
import '../api/nga_client.dart';
import '../models/models.dart';
import '../utils/reply_tree.dart';
import '../widgets/post_card.dart';

class ThreadScreen extends StatefulWidget {
  final int tid;
  final int fid;
  final String title;
  const ThreadScreen({super.key, required this.tid, required this.fid, required this.title});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final _client = NgaClient();
  List<({Post post, int depth})> _flatNodes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _loading = true;
  Thread? _thread;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await _client.getThreadDetail(widget.tid, page: _currentPage);
      final tree = buildReplyTree(result.posts);
      if (mounted) {
        setState(() {
          _thread = result.thread;
          _flatNodes = flattenTree(tree);
          _totalPages = result.totalPages;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goPage(int p) {
    if (p < 1 || p > _totalPages) return;
    _currentPage = p;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_thread != null)
                          Text(
                            '${_thread!.author} · ${_thread!.replyCount} 回复',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            // Posts
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _flatNodes.isEmpty
                      ? Center(child: Text('暂无回复', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: _flatNodes.length,
                          itemBuilder: (_, i) {
                            final entry = _flatNodes[i];
                            Post? replyTarget;
                            if (entry.post.replyTo != null) {
                              for (final p in _flatNodes.map((e) => e.post)) {
                                if (p.floor == entry.post.replyTo) { replyTarget = p; break; }
                              }
                            }
                            return PostCard(
                              post: entry.post,
                              depth: entry.depth,
                              replyTarget: replyTarget,
                              isOP: entry.post.floor == 0 && entry.depth == 0,
                            );
                          },
                        ),
            ),
            // Pagination
            if (_totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pageBtn(_currentPage > 1 ? _currentPage - 1 : null, '<'),
                    ...List.generate(_totalPages.clamp(0, 5), (i) {
                      final p = _totalPages <= 5 ? i + 1 : (_currentPage <= 3 ? i + 1 : _totalPages - 4 + i);
                      return _pageBtn(p, '$p', isActive: p == _currentPage);
                    }),
                    _pageBtn(_currentPage < _totalPages ? _currentPage + 1 : null, '>'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pageBtn(int? page, String label, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 40,
        height: 40,
        child: TextButton(
          onPressed: page != null ? () => _goPage(page) : null,
          style: TextButton.styleFrom(
            backgroundColor: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            foregroundColor: isActive ? Colors.white : Colors.white70,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.zero,
          ),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
