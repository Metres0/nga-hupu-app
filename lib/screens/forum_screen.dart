import 'package:flutter/material.dart';
import '../api/nga_client.dart';
import '../models/models.dart';
import '../widgets/thread_card.dart';

class ForumScreen extends StatefulWidget {
  final BoardNode board;
  const ForumScreen({super.key, required this.board});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _client = NgaClient();
  List<Thread> _threads = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await _client.getForumThreads(widget.board.fid, page: _currentPage);
      if (mounted) {
        setState(() {
          _threads = result.threads;
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.board.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            // Thread list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async { _currentPage = 1; await _load(); },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _threads.length,
                        itemBuilder: (_, i) => ThreadCard(
                          thread: _threads[i],
                          onTap: () => Navigator.pushNamed(context, '/thread', arguments: {
                            'tid': _threads[i].tid,
                            'fid': widget.board.fid,
                            'title': _threads[i].title,
                          }),
                        ),
                      ),
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
                    const SizedBox(width: 4),
                    ...List.generate(_totalPages.clamp(0, 5), (i) {
                      final p = _totalPages <= 5 ? i + 1 : (_currentPage <= 3 ? i + 1 : _totalPages - 4 + i);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _pageBtn(p, '$p', isActive: p == _currentPage),
                      );
                    }),
                    const SizedBox(width: 4),
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
    return SizedBox(
      width: 40,
      height: 40,
      child: TextButton(
        onPressed: page != null ? () => _goPage(page) : null,
        style: TextButton.styleFrom(
          backgroundColor: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          foregroundColor: isActive ? Colors.white : Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
