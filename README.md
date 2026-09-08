# Codex 剩余用量 · v0.3.7

一个只读的 macOS 菜单栏监控器：从本机 Codex App Server 和会话日志读取用量与任务状态，在菜单栏显示 5 小时、7 天窗口的剩余比例，并保留任务进度面板。

## v0.3.7 更新

- 使用官方 Codex App Server 的只读 `account/rateLimits/read` 与 `account/rateLimits/updated`，不创建对话、不启动模型回合。
- 按 `windowDurationMins` 识别约 300 分钟的 5 小时窗口和约 10080 分钟的 7 天窗口，不按数组顺序猜测。
- 事件到达时立即刷新；无事件时每 10 秒最多补读一次。断线重连期间保留最近有效快照，并显示同步状态。
- 菜单栏剩余量按 50% 以上、20%—50%、20% 以下使用自适应高对比颜色。
- 任务进度面板保留进行中/已完成分区、深链 `codex://threads/<session_id>`、详情窗口、处理时间、授权提示和无滚动布局。
- 任务 token 以会话日志为隔离边界；任务行显示本轮新增量，详情中的累计值直接读取各日志最新 `total_token_usage` 快照并去重，支持多个任务并行运行。
- 全进程使用单实例锁、单一用量同步服务和单一状态栏项目，避免重复窗口与重复读取。

## 构建与运行

要求 macOS 和 Swift 编译器，不需要第三方依赖：

```bash
cd "/Users/zhengshenyuan/Desktop/codex文件夹/codex-usage-menu"
./build-app.sh
open CodexUsageMenu.app
```

如需离线验收而不覆盖默认输出：

```bash
CODEX_USAGE_BUILD_APP_DIR=/private/tmp/CodexUsageMenu-preview.app ./build-app.sh
```

解析器冒烟测试：

```bash
cache=$(mktemp -d /private/tmp/codex-remaining-usage-module-cache.XXXXXX)
swiftc Sources/UsageSnapshot.swift Sources/OfficialUsageClient.swift \
  Tests/UsageSyncParserSmoke.swift -module-cache-path "$cache" \
  -o /private/tmp/UsageSyncParserSmoke
/private/tmp/UsageSyncParserSmoke
```

## 数据边界与隐私

程序只读取当前用户本机的 Codex App Server 限额响应和会话日志；不上传任务标题或日志正文，不执行网页或账户操作，不读取或保存 Cookie、认证 Token、账户标识、截图、千川文件或备份包。官方限额快照与本地日志 token 统计是不同口径，菜单栏以官方限额为准，任务详情以本地日志为准。

## 版本

- `v0.3.7` — 2026-09-08：官方用量事件同步、断线保留快照、任务深链、并行 token 隔离和单实例任务面板整合版。

许可证见 [LICENSE](LICENSE)。
