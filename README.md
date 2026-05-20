# NGA 镜像站 — Flutter 客户端

基于 Flutter 3.32 的 NGA 论坛 Android 客户端，液态玻璃 UI，连接 Next.js 后端 API。

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Flutter 3.32 / Dart 3.6 |
| 状态管理 | Provider + ChangeNotifier |
| 网络 | `http` 包 |
| 图片 | `cached_network_image` |
| 存储 | `shared_preferences`（订阅持久化） |
| UI | Material 3 + BackdropFilter 液态玻璃 |
| 后端 | Next.js 14 API (localhost:3000) |

## 快速开始

```bash
# 1. 克隆
git clone https://github.com/Metres0/nga-hupu-app.git
cd nga_hupu_app

# 2. 确保 Web 服务端运行
# cd ../nga-hupu && npm run start

# 3. 构建安装
flutter pub get
flutter build apk --debug
flutter install
```

## 项目结构

```
lib/
├── main.dart                       # 入口 + MaterialApp + 路由
├── models/models.dart              # BoardNode / Thread / Post
├── api/nga_client.dart             # HTTP 客户端
├── parser/bbcode.dart              # BBCode 解析器
├── utils/reply_tree.dart           # 回复树算法
├── providers/subscription_provider.dart  # 订阅状态
├── screens/
│   ├── home_screen.dart            # 板块搜索/订阅/折叠 (366 板块)
│   ├── forum_screen.dart           # 帖子列表 + 下拉刷新 + 翻页
│   └── thread_screen.dart          # 回复树 + 图片灯箱
└── widgets/
    ├── glass_card.dart             # 液态玻璃 BackdropFilter
    ├── board_card.dart             # 板块卡片 + 订阅按钮
    ├── thread_card.dart            # 帖子卡片
    └── post_card.dart              # 回复卡片 + depth 缩进 + ImageGallery
```

## 连接 Web 服务端

默认连接 `http://localhost:3000`。修改 `lib/api/nga_client.dart` 中的 `baseUrl` 可指向远程服务器。

```dart
NgaClient({this.baseUrl = 'http://localhost:3000'});
```

## 后续优化方向

### Web 端
- **增量抓取**：对比 SQLite 新增 TID，仅抓取变更
- **定时刷新**：cron 每 30 分钟自动运行 `scrape-all.ts`
- **全文搜索**：SQLite FTS5 索引 `posts` 表
- **亮色主题**：CSS 变量亮/暗切换
- **RSS 输出**：`/api/v1/rss/:fid`
- **多板块并发**：Pool 5 抓取代串行

### Android 端
- **离线缓存**：`sqflite` 本地 SQLite 缓存帖子
- **通知推送**：FCM + WorkManager 后台检查新帖提醒
- **Deep Link**：`intent-filter` 支持 `ngahupu://thread/123`
- **连接池**：`http.Client` keep-alive 复用
- **暗色主题切换**：Material You dynamic color
- **性能**：`const` widget + `RepaintBoundary` + `ListView.builder`

## 许可证

仅供学习交流使用。NGA 相关数据版权归 bbs.nga.cn 所有。
