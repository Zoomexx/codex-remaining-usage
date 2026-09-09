# Codex 剩余用量 · v0.3.8

一个只读的 macOS 菜单栏监控器。它从官方 Codex App Server 读取账户限额快照，在菜单栏显示 5 小时和 7 天窗口的剩余比例；同时保留同系列的任务进度面板和本地 token 统计。

## 功能说明

### 1. 官方剩余用量

- 启动时只读调用 `account/rateLimits/read`，正常运行时订阅 `account/rateLimits/updated`。
- 按 `windowDurationMins` 将约 300 分钟映射为 5 小时窗口，将约 10080 分钟映射为 7 天窗口，不依赖数组顺序。
- 事件到达时即时刷新；无事件时每 10 秒最多补读一次。
- 显示剩余百分比、重置时间、最后同步时间和同步/延迟/过期状态。
- 断线重连时保留最近有效快照，不用空值静默覆盖已有数字。

### 2. 菜单栏呈现

- 状态栏显示 `Codex · 5h …% · 7d …%`。
- 剩余量 50% 及以上、20%—50%、低于 20% 使用不同的高对比颜色，并适配浅色/深色模式。
- 点击菜单栏项目可查看窗口说明、重置时间、同步状态、最后同步时间和会话 token 摘要。
- “立即刷新”只触发官方只读读取，不发送聊天消息，不创建任务，也不启动模型回合。

### 3. 任务进度面板

- 从 `~/.codex/sessions` 和 `~/.codex/session_index.jsonl` 读取任务名称、状态、步骤、耗时和明细。
- 进行中/等待中位于上方，已完成/已中断/空闲位于下方；每栏显示最近任务，其余任务进入独立详情窗口。
- 点击任务使用 `codex://threads/<session_id>` 打开对应对话；深链不可用时回退到应用或本地日志。
- 保留待授权提示、悬停透明度、无滚动布局、自动隐藏详情窗口和单实例保护。

### 4. Token 统计口径

- 任务行显示以 `task_started` 为边界的本轮新增 token。
- 详情页累计值直接读取每个会话日志最新的 `total_token_usage`，按日志文件去重，不把各任务本轮消耗相加。
- 日志文件是并行任务的隔离边界，多个任务同时运行时不会串用基线。
- 本地 token 是日志估算，不等同于 OpenAI 账单；官方限额和本地 token 是两套不同口径。

### 5. 底部运行状态动画

- 任务面板底部空白区在有进行中/等待中任务时显示低干扰横向运行线。
- 动画只使用一个变换图层，不改变布局；普通任务刷新不会重置动画，因此不会断续闪烁。
- 运行线以上一行任务实际下缘为基准居中；开启 macOS“减少动态效果”后显示静态提示。

### 6. 单实例与可靠性

- 全进程只有一个状态栏项目、一个用量同步服务、一个 App Server 连接和一个任务面板。
- 事件、补读、断线重连和唤醒后的恢复由同一同步服务管理。
- 解析器使用窗口时长映射和快照状态，不把空读或连接暂时失败误判为零用量。

## 构建与运行

要求 macOS 和 Swift 编译器，不需要第三方依赖：

```bash
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

## 数据来源与隐私边界

- 官方剩余用量只来自本机 Codex App Server 的只读限额响应；任务和 token 只来自本机 Codex 会话日志。
- 不上传任务标题、日志正文或账户数据，不执行网页或账户操作，不读取或保存 Cookie、认证 Token、账户标识、截图、千川文件或备份包。
- 不读取 ChatGPT App 私有数据库、浏览器缓存或账户文件。
- 官方限额读取不会创建对话、任务或模型回合。

## 版本

- `v0.3.8` — 2026-09-09：增加底部运行状态动画；修复任务刷新/布局导致的动画断续；补充菜单栏、任务面板、token 口径、单实例和隐私边界说明。
- `v0.3.7` — 2026-09-08：官方用量事件同步、断线快照、任务深链、并行 token 隔离和单实例任务面板整合版。

许可证见 [LICENSE](LICENSE)。
