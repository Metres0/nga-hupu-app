/// NGA 数据模型 — 对等 TypeScript types.ts
class Thread {
  final int tid;
  final int fid;
  final String title;
  final String author;
  final int authorId;
  final int createTime;
  final int lastReplyTime;
  final int replyCount;
  final bool sticky;
  final bool digest;
  final List<String> categories;
  final int pageCount;

  const Thread({
    required this.tid,
    required this.fid,
    required this.title,
    required this.author,
    this.authorId = 0,
    required this.createTime,
    required this.lastReplyTime,
    this.replyCount = 0,
    this.sticky = false,
    this.digest = false,
    this.categories = const [],
    this.pageCount = 1,
  });

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
        tid: json['tid'] as int? ?? 0,
        fid: json['fid'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        authorId: json['authorId'] as int? ?? 0,
        createTime: json['createTime'] as int? ?? 0,
        lastReplyTime: json['lastReplyTime'] as int? ?? 0,
        replyCount: json['replyCount'] as int? ?? 0,
        sticky: json['sticky'] as bool? ?? false,
        digest: json['digest'] as bool? ?? false,
        categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
        pageCount: json['pageCount'] as int? ?? 1,
      );
}

class Post {
  final int pid;
  final int tid;
  final String author;
  final String content;
  final String contentHtml;
  final int createTime;
  final int? replyTo;
  final int floor;
  final List<String> images;
  final int likes;

  const Post({
    required this.pid,
    required this.tid,
    required this.author,
    required this.content,
    this.contentHtml = '',
    required this.createTime,
    this.replyTo,
    required this.floor,
    this.images = const [],
    this.likes = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        pid: json['pid'] as int? ?? 0,
        tid: json['tid'] as int? ?? 0,
        author: json['author'] as String? ?? '',
        content: json['content'] as String? ?? '',
        contentHtml: json['contentHtml'] as String? ?? '',
        createTime: json['createTime'] as int? ?? 0,
        replyTo: json['replyTo'] as int?,
        floor: json['floor'] as int? ?? 0,
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
        likes: json['likes'] as int? ?? 0,
      );
}

class BoardNode {
  final int fid;
  final String name;
  final int? parentFid;
  final List<BoardNode> children;

  const BoardNode({
    required this.fid,
    required this.name,
    this.parentFid,
    this.children = const [],
  });

  factory BoardNode.fromJson(Map<String, dynamic> json) => BoardNode(
        fid: json['fid'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        parentFid: json['parent_fid'] as int?,
      );
}
