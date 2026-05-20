/// BBCode → Flutter Widget 解析器
/// 纯函数，翻译自 TypeScript src/lib/parser/bbcode.ts
String proxyImgUrl(String url) {
  if (url.startsWith('/api') || url.startsWith('data:')) return url;
  return '/api/v1/image-proxy?url=${Uri.encodeComponent(url)}';
}

String bbcodeToHtml(String raw) {
  if (raw.isEmpty) return '';
  String html = raw;
  html = html.replaceAll('\r\n', '\n');
  html = html.replaceAll(RegExp(r'\n{2,}'), '</p><p>');
  html = html.replaceAll('\n', '<br>');
  html = '<p>$html</p>';
  html = html.replaceAll(RegExp(r'<p>\s*</p>'), '');

  // Bold
  html = html.replaceAll(RegExp(r'\[b\](.*?)\[/b\]', dotAll: true, caseSensitive: false), '<strong>\$1</strong>');
  // Italic
  html = html.replaceAll(RegExp(r'\[i\](.*?)\[/i\]', dotAll: true, caseSensitive: false), '<em>\$1</em>');
  // Underline
  html = html.replaceAll(RegExp(r'\[u\](.*?)\[/u\]', dotAll: true, caseSensitive: false), '<u>\$1</u>');
  // Strikethrough
  html = html.replaceAll(RegExp(r'\[del\](.*?)\[/del\]', dotAll: true, caseSensitive: false), '<del>\$1</del>');
  html = html.replaceAll(RegExp(r'\[s\](.*?)\[/s\]', dotAll: true, caseSensitive: false), '<del>\$1</del>');

  // Color
  html = html.replaceAll(RegExp(r'\[color=([^\]]+)\](.*?)\[/color\]', dotAll: true, caseSensitive: false),
      '<span style="color:\$1">\$2</span>');

  // Size
  html = html.replaceAll(RegExp(r'\[size=([^\]]+)\](.*?)\[/size\]', dotAll: true, caseSensitive: false),
      '<span style="font-size:\$1">\$2</span>');

  // Align
  html = html.replaceAll(RegExp(r'\[align=(left|center|right|justify)\](.*?)\[/align\]', dotAll: true, caseSensitive: false),
      '<div style="text-align:\$1">\$2</div>');

  // URL
  html = html.replaceAll(RegExp(r'\[url\](https?://[^\[]+?)\[/url\]', caseSensitive: false),
      '<a href="\$1">\$1</a>');
  html = html.replaceAll(RegExp(r'\[url=(https?://[^\]]+?)\](.*?)\[/url\]', caseSensitive: false),
      '<a href="\$1">\$2</a>');

  // Image with proxy
  html = html.replaceAllMapped(
    RegExp(r'\[img\](https?://[^\[]+?\.(?:jpg|jpeg|png|gif|webp|bmp)[^\[]*?)\[/img\]', caseSensitive: false),
    (m) => '<img src="${proxyImgUrl(m.group(1)!)}" />',
  );

  // Quote
  html = html.replaceAll(RegExp(r'\[quote\](.*?)\[/quote\]', dotAll: true),
      '<blockquote>\$1</blockquote>');
  html = html.replaceAll(RegExp(r'\[quote\s+pid=(\d+)\](.*?)\[/quote\]', dotAll: true, caseSensitive: false),
      '<blockquote data-pid="\$1"><span class="bb-quote-header">回复 #\$1</span>\$2</blockquote>');

  // Collapse
  html = html.replaceAll(RegExp(r'\[collapse(?:\s*=\s*(.+?))?\](.*?)\[/collapse\]', dotAll: true, caseSensitive: false),
      '<details><summary>\${1:展开}</summary>\$2</details>');

  // List
  html = html.replaceAll(RegExp(r'\[list\](.*?)\[/list\]', dotAll: true, caseSensitive: false), (match) {
    final content = RegExp(r'\[list\](.*?)\[/list\]', dotAll: true).firstMatch(match)?.group(1) ?? '';
    final items = content.split('[*]').where((s) => s.trim().isNotEmpty).map((s) => '<li>${s.trim()}</li>').join();
    return '<ul>$items</ul>';
  });

  // Table
  html = html.replaceAll(RegExp(r'\[table\](.*?)\[/table\]', dotAll: true, caseSensitive: false), (match) {
    final content = RegExp(r'\[table\](.*?)\[/table\]', dotAll: true).firstMatch(match)?.group(1) ?? '';
    final rows = content.split('[tr]').where((s) => s.contains(']')).map((row) {
      final clean = row.replaceAll('[/tr]', '').trim();
      final cells = clean.replaceAllMapped(RegExp(r'\[/?t[dh]\]', caseSensitive: false), (m) {
        if (m.group(0)!.startsWith('[/')) return m.group(0)!.contains('[th]') ? '</th>' : '</td>';
        return m.group(0)!.contains('[th]') ? '<th>' : '<td>';
      });
      return '<tr>$cells</tr>';
    }).join();
    return '<div style="overflow-x:auto"><table border="1" cellpadding="4" style="border-collapse:collapse">$rows</table></div>';
  });

  // Code
  html = html.replaceAll(RegExp(r'\[code\](.*?)\[/code\]', dotAll: true, caseSensitive: false),
      '<pre><code>\$1</code></pre>');

  // Clean JS
  html = html.replaceAll(RegExp(r'ubbcode\.attach\.load\([^)]+\)'), '');
  html = html.replaceAll('显示全部附件', '');
  html = html.replaceAll(RegExp(r'<img[^>]+about:blank[^>]*>', caseSensitive: false), '');

  return html;
}
