import '../models/models.dart';

class ReplyNode {
  final Post post;
  final int depth;
  final List<ReplyNode> children;

  ReplyNode({required this.post, this.depth = 0, this.children = const []});
}

/// 构建回复树：按 replyTo 字段将平铺帖子转为树结构
List<ReplyNode> buildReplyTree(List<Post> posts) {
  final roots = <ReplyNode>[];
  final nodeMap = <int, ReplyNode>{};

  for (final post in posts) {
    nodeMap[post.floor] = ReplyNode(post: post);
  }

  for (final post in posts) {
    final node = nodeMap[post.floor]!;
    if (post.replyTo != null && nodeMap.containsKey(post.replyTo)) {
      final parent = nodeMap[post.replyTo]!;
      node.depth = (parent.depth + 1).clamp(0, 5);
      parent.children.add(node);
    } else {
      roots.add(node);
    }
  }

  _sortChildren(roots);
  return roots;
}

void _sortChildren(List<ReplyNode> nodes) {
  nodes.sort((a, b) => a.post.floor.compareTo(b.post.floor));
  for (final node in nodes) {
    _sortChildren(node.children);
  }
}

/// 将回复树平铺为有序列表，每项带 depth
List<({Post post, int depth})> flattenTree(List<ReplyNode> nodes) {
  final result = <({Post post, int depth})>[];
  void walk(List<ReplyNode> list) {
    for (final node in list) {
      result.add((post: node.post, depth: node.depth));
      walk(node.children);
    }
  }
  walk(nodes);
  return result;
}
