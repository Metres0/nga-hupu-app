import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class NgaClient {
  final String baseUrl;

  NgaClient({this.baseUrl = 'http://localhost:3000'});

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// 获取板块树
  Future<List<BoardNode>> getBoards() async {
    final json = await _get('/api/v1/boards');
    final list = json['forums'] as List<dynamic>? ?? [];
    return list.map((e) => BoardNode.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取论坛帖子列表
  Future<({List<Thread> threads, int totalPages, String name})> getForumThreads(
    int fid, {int page = 1}
  ) async {
    final json = await _get('/api/v1/forums/$fid?page=$page');
    final data = json['data'] as List<dynamic>? ?? [];
    final threads = data.map((e) => Thread.fromJson(e as Map<String, dynamic>)).toList();
    final forum = json['forum'] as Map<String, dynamic>? ?? {};
    return (
      threads: threads,
      totalPages: json['totalPages'] as int? ?? 1,
      name: forum['name'] as String? ?? '',
    );
  }

  /// 获取帖子详情
  Future<({Thread thread, List<Post> posts, int totalPages})> getThreadDetail(
    int tid, {int page = 1}
  ) async {
    final json = await _get('/api/v1/threads/$tid?page=$page');
    final t = json['thread'] as Map<String, dynamic>? ?? {};
    final ps = json['posts'] as List<dynamic>? ?? [];
    return (
      thread: Thread.fromJson(t),
      posts: ps.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
