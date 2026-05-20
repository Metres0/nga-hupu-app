import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/nga_client.dart';
import '../models/models.dart';
import '../providers/subscription_provider.dart';
import '../widgets/board_card.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _client = NgaClient();
  final _searchCtrl = TextEditingController();
  List<BoardNode> _boards = [];
  bool _loading = true;
  bool _showMore = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    try {
      final boards = await _client.getBoards();
      if (mounted) setState(() { _boards = boards; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>().subscribed;
    final subscribedBoards = _boards.where((b) => sub.contains(b.fid)).toList();
    final unsubscribed = _boards.where((b) => !sub.contains(b.fid)).toList();
    final filtered = _search.isEmpty
        ? unsubscribed
        : unsubscribed.where((b) => b.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              title: const Text('NGA 镜像站', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              centerTitle: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '搜索 ${_boards.length} 个板块...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.4)),
                                onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Subscribed
            if (subscribedBoards.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⭐ 已订阅 (${subscribedBoards.length})',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ...subscribedBoards.map((b) => BoardCard(
                          board: b,
                          isSubscribed: true,
                          onToggle: () => context.read<SubscriptionProvider>().toggle(b.fid),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            // More boards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showMore = !_showMore),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _search.isNotEmpty ? '搜索结果 (${filtered.length})' : '更多板块 (${unsubscribed.length})',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                            ),
                            Icon(
                              _showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      if (_showMore) ...[
                        const SizedBox(height: 4),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text('未找到匹配板块', style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13)),
                            ),
                          )
                        else
                          ...filtered.take(100).map((b) => BoardCard(
                            board: b,
                            isSubscribed: false,
                            onToggle: () => context.read<SubscriptionProvider>().toggle(b.fid),
                          )),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
