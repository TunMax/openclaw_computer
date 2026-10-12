# openclaw_computer

> 🖥️ 一个预装 [OpenClaw](https://docs.openclaw.ai/zh-CN) 的浏览器桌面容器：部署后打开网页就是一台中文 Linux 云电脑，填入免费的 ModelScope 访问令牌即可开始畅玩。

**适配环境**：ModelScope 创空间（免费 2 核 16GB）· HuggingFace Spaces（`hf_edition` 镜像）· 本地 Docker · 其他 Docker 云平台

**快速导航**：[你会得到什么](#-你会得到什么) ｜ [快速开始](#-快速开始) ｜ [进入桌面先玩这 5 件事](#-进入桌面后先玩这-5-件事) ｜ [环境变量](#%EF%B8%8F-环境变量) ｜ [自动备份与恢复](#-自动备份与恢复) ｜ [进阶玩法](#-进阶玩法) ｜ [路径与端口](#-路径与端口速查) ｜ [常见问题](#-常见问题faq) ｜ [镜像与版本](#-镜像与版本)

---

## 🎁 你会得到什么

| 能力 | 说明 |
| --- | --- |
| 🖥️ **浏览器里的云电脑** | KDE Plasma 中文桌面，基于 TigerVNC + noVNC，打开网页自动连接，无需安装任何客户端 |
| 🤖 **开箱即用的 OpenClaw** | 默认接入 ModelScope 免费推理模型，只需提供一个访问令牌 |
| 🌐 **Google Chrome** | 启动后自动打开 OpenClaw 控制台，即开即用 |
| ⌨️ **中文输入法** | Fcitx5 拼音，`Ctrl + Shift` 切换中英文 |
| 🧰 **常用软件齐全** | Konsole 终端、Dolphin 文件管理器、VS Code、Ark 解压工具、htop、tmux、zsh、croc 等 |
| 🧠 **内置 Pi Agent** | 桌面图标一键打开 AI 编程助手，默认复用 ModelScope 模型 |
| 💾 **自动备份 / 恢复** | 支持本地持久化目录、S3、WebDAV 三种后端，实时监听文件变化并同步 |
| 🧹 **纯净模式** | 一条环境变量即可跳过恢复与备份，专治「配置错误起不来」 |

> 桌面规格：**1920×1080 · 24 位色 · Asia/Shanghai 时区 · zh_CN.UTF-8 · KDE 特效已关闭（流畅优先）**
>
> ℹ️ 以上为 `latest` 主镜像的体验；HuggingFace 部署使用 `hf_edition`，默认以无桌面模式运行，详见「快速开始 · 方式二」。

---

## 🚀 快速开始

### 方式一：ModelScope 创空间（推荐，免费）

> 免费获得 2 核 16GB 云电脑，适合绝大多数用户直接体验。

1. 打开 [ModelScope 官网](https://www.modelscope.cn/home) 注册登录，按提示完成阿里云账号绑定与实名认证。
2. **获取访问令牌**：点击右上角头像 → **账号设置** → **访问控制** → **新建访问令牌**，复制令牌（形如 `ms-xxxxxxxx`）。
3. 打开创空间 [BrianZhou/openclaw_computer](https://www.modelscope.cn/studios/BrianZhou/openclaw_computer)，点击「**复制创空间**」。
4. **填写参数**：
   - **是否公开**：选择「**非公开**」（保护你的桌面隐私，重要）
   - **ROOT_PASSWD**：自定义桌面锁屏密码
   - **MODELSCOPE_API_KEY**：粘贴第 2 步复制的令牌
5. 确认后等待空间构建上线（首次构建需要几分钟）。
6. 状态变为「运行中」后，点击「**服务地址**」（7860 端口）即可进入桌面，noVNC 会自动连接。

📺 视频教程：[B 站](https://www.bilibili.com/video/BV1HQwtzuEmw)　｜　📝 图文教程：[微信公众号](https://mp.weixin.qq.com/s/gAQs3Zl9ohkcSFmQcd-Z-Q)

> 💡 想自建空间而不复制别人的？见下方「方式四：自建 ModelScope 空间」。

### 方式二：HuggingFace Spaces（hf_edition 镜像）

> HuggingFace 部署请使用专属镜像 `hf_edition`。它默认以**无桌面模式**运行：7860 端口直接提供 OpenClaw 控制台；设置 `PRO_MODE=1` 还会开启在线终端与在线文件管理，方便排查问题。

1. 在 HuggingFace 创建（或打开已有）一个 **Docker** 类型的 Space。
2. 在 Space 仓库中添加 `Dockerfile`，内容如下：

   ```dockerfile
   FROM ghcr.io/tunmax/openclaw_computer:hf_edition

   EXPOSE 7860

   ENTRYPOINT ["/entrypoint.sh"]
   ```

3. 在 Space 的 **Settings → Variables and secrets** 中添加 Secret：`MODELSCOPE_API_KEY` = 你的 ModelScope 访问令牌。
4. 点击 **Factory rebuild** 重新构建部署。
5. 构建完成后打开 Space 地址，即可直接使用 OpenClaw 控制台。

**可选配置**（同样在 Variables and secrets 中添加）：

| 变量 | 说明 |
| --- | --- |
| `PRO_MODE=1` | 专业模式：额外启动在线终端 `/bzshell` 与在线文件管理 `/bzfiles`（见「进阶玩法 · HuggingFace 专属功能」） |
| `DISABLE_DESKTOP=0` | 切换为完整 KDE 桌面模式（7860 变为 noVNC 桌面，与主镜像体验一致），仅限本地研究时使用，HF 平台上勿用 |
| S3 / WebDAV 相关变量 | 启用远程自动备份/恢复（见「自动备份与恢复」） |

> 💡 HuggingFace 提供 Buckets 功能，将 Bucket 挂载到 `/mnt/workspace` 路径即可启用本地自动备份/恢复（与 ModelScope 的 `/mnt/workspace` 逻辑一致）。

### 方式三：本地 Docker

```bash
docker run -d --name openclaw \
  -p 7860:7860 \
  -e MODELSCOPE_API_KEY=ms-xxxxxxxx \
  -e ROOT_PASSWD=123456 \
  -v ./openclaw-data:/mnt/workspace \
  ghcr.io/tunmax/openclaw_computer:latest
```

打开 **http://localhost:7860** 即可进入桌面。

| 常用操作 | 命令 |
| --- | --- |
| 查看启动日志 | `docker logs -f openclaw` |
| 进入容器终端 | `docker exec -it openclaw bash` |
| 停止容器 | `docker stop openclaw` |

> `-v ./openclaw-data:/mnt/workspace` 挂载后即启用**本地自动备份/恢复**，备份会写入 `./openclaw-data/root/`；不挂载则容器重启后数据会丢失。

### 方式四：自建 ModelScope 空间（使用 Dockerfile）

如果你不想复制别人的空间，可以新建一个 Docker 类型的创空间，Dockerfile 内容如下：

```dockerfile
FROM ghcr.io/tunmax/openclaw_computer:latest

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
```

然后在空间设置中配置（至少设置 `MODELSCOPE_API_KEY`）即可。

---

## 🎮 进入桌面后，先玩这 5 件事

1. **打开 OpenClaw 控制台** —— 容器启动时 Chrome 会自动打开。如果不小心关掉了，在 Konsole 终端执行：
   ```bash
   openclaw dashboard
   ```
   它会带着当前 token 重新打开控制台；也可以执行 `openclaw dashboard --no-open` 只打印带 token 的链接。
2. **切换中英文输入法** —— `Ctrl + Shift`。
3. **粘贴外部文字** —— 点击屏幕最左侧工具栏的「剪贴板」按钮（第 3 个），输入或粘贴文字后，即可在容器内 `Ctrl + V`。
4. **查看内置帮助** —— 桌面上的「使用帮助.html」。
5. **对 OpenClaw 说句话** —— 验证模型是否正常。默认使用 ModelScope 免费模型，若报错请检查 `MODELSCOPE_API_KEY` 是否填写正确。

常用命令速查：

```bash
openclaw gateway --force run   # 重启 Gateway（--force 会先结束旧进程）
openclaw doctor --fix --yes    # 健康检查并自动修复
openclaw status                # 查看 Gateway / 渠道 / 模型状态
openclaw dashboard             # 带 token 打开控制台
```

---

## ⚙️ 环境变量

### 基础配置

| 变量名 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `MODELSCOPE_API_KEY` | ✅ 建议填写 | `not_set_yet` | ModelScope 访问令牌，OpenClaw 与 Pi Agent 的默认模型都依赖它 |
| `ROOT_PASSWD` | 否 | `123456` | 桌面锁屏密码（长时间未操作自动锁屏时需输入） |
| `KEEP_ORIGINAL_CONF` | 否 | `1` | `1` = 启动时保留出厂配置副本到 `/root/.openclaw_origin`，便于随时对照或还原 |
| `SKIP_RESTORE` | 否 | `0` | `1` = **纯净模式**：跳过历史配置恢复、实时备份守护和用户自定义启动脚本（排障神器） |

### 桌面配置

| 变量名 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `VNC_PASSWD` | 否 | 无 | 设置后进入桌面需先输入 VNC 密码；不设置则无需密码 |
| `VNC_GEOMETRY` | 否 | `1920x1080` | 桌面分辨率 |
| `VNC_DEPTH` | 否 | `24` | 桌面色深 |

### HuggingFace 专属（`hf_edition` 镜像）

| 变量名 | 默认值 | 说明 |
| --- | --- | --- |
| `PRO_MODE` | `0` | `1` = 专业模式：启动在线终端 `/bzshell` 与在线文件管理 `/bzfiles` 的 url 路径，方便在 OpenClaw 异常时排查恢复 |
| `DISABLE_DESKTOP` | `1` | `1` = 无桌面模式（默认，7860 直接提供 OpenClaw 控制台）；`0` = 启动完整 KDE 桌面（noVNC） |

### 自动备份 / 恢复

后端选择优先级：**S3 > WebDAV > 本地 `/mnt/workspace`**。

#### S3 远程存储

| 变量名 | 默认值 | 说明 |
| --- | --- | --- |
| `S3_BUCKET` | 无 | 桶名。**非空即启用 S3 备份** |
| `S3_KEY_ID` | 无 | AccessKey ID |
| `S3_ACCESS_KEY` | 无 | AccessKey Secret |
| `S3_ENDPOINT` | `https://s3.cstcloud.cn` | S3 接入点，默认中科院[「数据胶囊」](https://data.cstcloud.cn) |
| `S3_BACKUP_PATH` | `backups/data.tar.gz` | 备份路径；可用不同路径保存多份备份（如 `user1/data.tar.gz`） |

#### WebDAV 远程存储

| 变量名 | 默认值 | 说明 |
| --- | --- | --- |
| `WEBDAV_URL` | 无 | 服务地址。**非空即启用 WebDAV 备份**（S3 优先） |
| `WEBDAV_USER` | 无 | 用户名 |
| `WEBDAV_PASSWD` | 无 | 密码 |
| `WEBDAV_CLIENT_UA` | `Zotero/8.0` | 请求 UA 头，数据胶囊服务要求 |
| `WEBDAV_BACKUP_PATH` | `backups/data.tar.gz` | 备份路径 |

#### 加密

| 变量名 | 默认值 | 说明 |
| --- | --- | --- |
| `BACKUP_ENC_PASS` | 无 | 设置后，备份文件在传输到远端前使用 GPG AES256 加密（端到端加密） |

---

## 💾 自动备份与恢复

### 备份哪些内容

| 路径 | 内容 |
| --- | --- |
| `/root/.openclaw` | OpenClaw 配置、会话、记忆、工作区 |
| `/root/Desktop` | 桌面文件 |
| `/root/bz-startup` | 用户自定义启动脚本 |
| `/root/.codex` / `/root/.claude` / `/root/.pi` | 各 AI 工具配置 |
| `/root/.zsh_history` | 终端命令历史 |

自动忽略：`.git`、`.venv`、`venv`、`node_modules`。

### 三种后端

| 后端 | 触发条件 | 备份位置 |
| --- | --- | --- |
| **S3** | 设置了 `S3_BUCKET` | `S3_BACKUP_PATH` 指定的对象 |
| **WebDAV** | 设置了 `WEBDAV_URL`（且未设置 S3） | `WEBDAV_BACKUP_PATH` 指定的文件 |
| **本地** | 容器内存在 `/mnt/workspace` 目录 | `/mnt/workspace/root/` |

- ModelScope 创空间自带 `/mnt/workspace` 持久化目录，**默认自动启用本地备份，无需任何配置**。
- 本地 Docker 需要挂载卷到 `/mnt/workspace` 才会启用。
- 配置 S3/WebDAV 后，可以在不同平台（如 ModelScope 与本地）之间无缝衔接同一份 OpenClaw 配置。

### 工作方式

1. **启动恢复**：容器启动时先从备份恢复配置，成功后才启动 OpenClaw Gateway。
2. **实时备份**：运行中通过 `inotifywait` 监听上述路径，文件变化后延迟 6 秒防抖，打包并同步一次（打包格式：`tar -zcPf`；远端传输使用 `rclone`）。
3. **失败保护**：已配置远端备份但下载/解包失败时，容器会**终止启动并报错**，避免坏数据覆盖运行环境。
4. **加密**：设置 `BACKUP_ENC_PASS` 时，先 GPG AES256 加密再上传；恢复时优先按加密解包，并兼容早期未加密备份。

### 手动操作与日志

```bash
/bz/sync_init.sh      # 手动执行一次配置恢复
/bz/sync_daemon.sh    # 手动启动实时备份守护进程
/bz/auto_recover.sh   # 恢复 + 执行自定义脚本 + 启动备份守护
```

| 日志 | 路径 |
| --- | --- |
| 实时备份守护 | `/tmp/bz-sync-daemon.log` |
| OpenClaw Gateway | `/tmp/openclaw_gateway.log` |

---

## 🧩 进阶玩法

### 自定义启动脚本

把希望在容器每次启动时执行的命令写入 `/root/bz-startup/main.sh`（该目录会自动备份/恢复），适合开机拉起自己的服务。

### 备份 Chrome 书签 / 浏览历史

Chrome 数据体积较大，不在默认备份范围内，但可以通过自定义启动脚本实现：

```bash
#!/bin/bash

# 恢复 Chrome 历史数据
rsync -a "/mnt/workspace/chrome/" "/root/.config/google-chrome/Default/"

# 每 10 分钟备份一次 Chrome 数据
nohup bash -c '
while true; do
    rsync -a --delete "/root/.config/google-chrome/Default/" "/mnt/workspace/chrome/"
    sleep 600
done
' > /dev/null 2>&1 &
```

### 使用 croc 在不同电脑间传文件

```bash
# 发送端（容器内）
croc send 文件名

# 接收端（另一台电脑，需先安装 croc）
croc <发送端生成的代码>
```

### 恢复出厂配置

当 OpenClaw 配置被改乱时，可以使用启动时保留的出厂副本：

```bash
mv /root/.openclaw /root/.openclaw.broken      # 保留现场
cp -a /root/.openclaw_origin /root/.openclaw   # 还原出厂配置
openclaw gateway --force run                   # 重启 Gateway
```

### 更换模型

OpenClaw 配置文件位于 `/root/.openclaw/openclaw.json`，也可以使用 `openclaw configure` 交互式修改。当前镜像默认接入 ModelScope 免费模型：

- 默认主模型：`Qwen/Qwen3.8-Flash-Next`
- 备选模型：`DeepSeek-V4.1-Flash`、`Qwen/Qwen3.8-27B`、`stepfun-ai/Step-3.7-Flash`

### HuggingFace 专属功能（`hf_edition`）

`hf_edition` 默认以无桌面模式运行，内置 Caddy 在 7860 端口统一提供以下服务：

| 路径 | 功能 | 说明 |
| --- | --- | --- |
| `/` | OpenClaw 控制台 | 反代到容器内的 Gateway（18789） |
| `/bzshell` | 在线终端 | 设置 `PRO_MODE=1` 后可用，基于 WebSocket + zsh，适合在 OpenClaw 进程异常时排查与恢复 |
| `/bzfiles` | 在线文件管理 | 设置 `PRO_MODE=1` 后可用，基于 copyparty，可浏览、上传、下载 `/root` 下的文件 |

访问地址形如：

- 在线终端：`https://<用户名>-<空间名>.hf.space/bzshell`
- 在线文件管理：`https://<用户名>-<空间名>.hf.space/bzfiles`

> 若设置 `DISABLE_DESKTOP=0` 切换为桌面模式，7860 端口会变为 noVNC 桌面，上述 `/bzshell`、`/bzfiles` 入口不再提供。

---

## 📁 路径与端口速查

| 端口 | 用途 | 暴露范围 |
| --- | --- | --- |
| `7860` | 浏览器访问入口（主镜像：noVNC 桌面；`hf_edition`：OpenClaw 控制台 / `/bzshell` / `/bzfiles`） | 对外 |
| `5901` | TigerVNC（noVNC 的后端） | 容器内部 |
| `18789` | OpenClaw Gateway / 控制台 | 仅容器 loopback |

| 路径 | 说明 |
| --- | --- |
| `/entrypoint.sh` | 容器入口脚本（启动编排） |
| `/bz/lib/*.sh` | 启动流程实现（`common` / `desktop` / `openclaw` / `sync`） |
| `/bz/sync_init.sh`、`/bz/sync_daemon.sh`、`/bz/auto_recover.sh` | 备份/恢复手动入口 |
| `/bz/rules.txt`、`/bz/watch.txt` | 备份过滤规则 / 实时监听列表 |
| `/root/.openclaw` | OpenClaw 配置与数据 |
| `/root/.openclaw_origin` | 出厂配置副本 |
| `/root/bz-startup/main.sh` | 用户自定义启动脚本 |
| `/mnt/workspace` | 持久化目录（本地备份根） |
| `/root/Desktop/使用帮助.html` | 桌面使用帮助 |

---

## ❓ 常见问题（FAQ）

**1. 容器重启后数据会丢吗？**

取决于备份后端：

- **ModelScope 创空间**：`/mnt/workspace` 是持久化目录，默认自动恢复；注意同一账号下不同创空间之间不互通。
- **HuggingFace Spaces**：默认没有持久化存储，需要把 Bucket 挂载到 `/mnt/workspace`，或配置 S3 / WebDAV。
- **本地 Docker**：需要把卷挂载到 `/mnt/workspace`，否则容器重启后数据会丢。
- **S3 / WebDAV**：配置后可在任何平台恢复，推荐需要长期保存的用户使用。

**2. OpenClaw 配置错误导致容器无限重启、无法进入桌面怎么办？**

设置环境变量 `SKIP_RESTORE=1`，以纯净模式启动（跳过历史配置恢复、实时备份和自定义启动脚本），进入桌面修复配置后，再移除该变量重启。

**3. 如何更新到最新镜像？**

- **ModelScope**：在「空间管理」中点击「重新部署」，会自动拉取最新镜像。
- **本地 Docker**：`docker pull ghcr.io/tunmax/openclaw_computer:latest` 后重建容器。

**4. Chrome 没有打开 OpenClaw 控制台 / 提示 token 无效？**

在终端执行 `openclaw dashboard`，它会读取当前配置中的 token 并打开控制台；也可以 `openclaw dashboard --no-open` 只打印链接。

**5. 为什么有时候用起来很卡？**

ModelScope / HuggingFace 的免费 2 核 16GB 配置**没有 SLA**，高峰期（一般是晚上）闲置资源少就会卡，低峰期则流畅。本容器已默认关闭 KDE 全部特效以保证流畅度。

**6. 如何切换中英文输入法？**

鼠标点击输入框后，按 `Ctrl + Shift` 切换。

**7. 如何把外面的文字粘贴进容器？**

点击屏幕最左侧工具栏的第 3 个按钮调出剪贴板，输入或粘贴文字后，即可在容器内 `Ctrl + V`。

**8. 云端备份恢复失败，容器起不来怎么办？**

这是有意设计的安全保护：远端已配置但下载/解包失败时会终止启动。请先对云端配置文件做好拷贝备份，检查 S3/WebDAV 配置后重启容器重试；急需进入桌面时可先用 `SKIP_RESTORE=1`。

**9. 创空间被自动休眠后，桌面上的文件还在吗？**

ModelScope 长时间无操作会休眠容器。`/mnt/workspace` 中的备份会保留，容器唤醒后自动恢复；而备份范围之外的文件可能丢失。

**10. HuggingFace 上 OpenClaw 起不来 / 服务异常，怎么排查？**

在 Space 设置中把 `PRO_MODE` 设为 `1` 并重启，然后访问 `https://<用户名>-<空间名>.hf.space/bzshell` 使用在线终端查看日志、修复配置；也可以访问 `/bzfiles` 在线管理文件。

---

## ⚠️ 重要提醒

- **请勿在 ModelScope / HuggingFace 等平台部署内网穿透相关服务。** 根据有关案例，平台检测到此类服务后可能会删除容器并停止账号。
- 免费实例没有 SLA，**请勿存放重要且无备份的数据**；建议把「是否公开」设为非公开，并设置 `ROOT_PASSWD` / `VNC_PASSWD`。
- 容器默认以 root 运行，OpenClaw 在容器内拥有完整工具权限（执行命令、操作浏览器等）。请勿将桌面地址分享给他人，并注意使用边界。

---

## 📦 镜像与版本

### 当前维护

| 镜像 | 说明 |
| --- | --- |
| `ghcr.io/tunmax/openclaw_computer:latest` | 主镜像（OpenClaw 版），适配 ModelScope、本地 Docker 等场景 |
| `ghcr.io/tunmax/openclaw_computer:hf_edition` | HuggingFace Spaces 专属镜像，支持 `PRO_MODE` 专业模式（在线终端 / 在线文件管理） |
| `ghcr.io/tunmax/openclaw_computer:20261011.post1` 等日期标签 | 固定版本，便于回滚 |

当前主镜像主要组件：OpenClaw `2026.10.1` · Node.js `v24.21.0` · Google Chrome `155` · KDE Plasma `5.27` · Debian 12。

### 已停止维护的历史镜像（仅存档）

> ⚠️ 以下镜像已停止更新，不建议新用户使用；相关部署教程仅作历史参考。

| 镜像 | 说明 | 最后更新 |
| --- | --- | --- |
| `qwenpaw_latest` | QwenPaw 版镜像（原 CoPaw 改名而来） | 2026-06-02 |
| `hermes_latest` | Hermes 版镜像 | 2026-06-02 |

仍在使用上述镜像的用户，建议迁移到 `latest` 主镜像；对应的历史版本标签（如 `qwenpaw_20260602`）仍可在 GHCR 拉取。

---

## 🛠️ 附：容器启动时发生了什么（给好奇的人）

`/entrypoint.sh` 的完整流程（实现拆分在 `/bz/lib/`）：

1. **初始化环境**：设置 `zh_CN.UTF-8` locale、`DISPLAY=:1`，检查 `vncserver / websockify / curl / jq` 等必需命令。
2. **启动桌面**：
   - 清理上次残留的 VNC 进程与 X 锁文件；
   - 启动 TigerVNC（`:1`，端口 `5901`，默认 `1920x1080`；设置 `VNC_PASSWD` 时启用密码认证）；
   - 等待 VNC 就绪，加载 DBus 会话环境（`/tmp/dbus-session.env`）；
   - 启动 noVNC / websockify（`0.0.0.0:7860`），即浏览器访问入口。
3. **设置 root 密码**：`ROOT_PASSWD`（默认 `123456`）。
4. **恢复配置 & 启动实时备份**（`SKIP_RESTORE=1` 时整步跳过）：
   - 保存出厂配置副本 `/root/.openclaw_origin`（`KEEP_ORIGINAL_CONF=1` 时）；
   - 按 S3 > WebDAV > 本地 `/mnt/workspace` 的优先级恢复历史配置；
   - 执行用户自定义启动脚本 `/root/bz-startup/main.sh`；
   - 后台启动实时备份守护 `/bz/sync_daemon.sh`；
   - ⚠️ 已配置远端备份但恢复失败时，容器**终止启动**并提示。
5. **启动 OpenClaw Gateway**：
   - 将 `openclaw.json`（JSON5）格式化为标准 JSON；
   - 执行 `openclaw doctor --fix --yes`；
   - `openclaw gateway --force run` 监听 `127.0.0.1:18789`，并等待端口与 HTTP 就绪（日志：`/tmp/openclaw_gateway.log`）。
6. **打开 Chrome**：自动打开控制台 `http://127.0.0.1:18789/#token=...` 与桌面「使用帮助.html」。
7. **守候**：进入守候状态；收到停止信号时依次清理 VNC / noVNC / Gateway / 备份守护进程后退出。

> 🎭 **演示模式**：当主机名包含 `-brianzhou-` 时，容器会应用 noVNC 只读补丁并清理本地持久化目录 —— 这是项目演示空间的专用逻辑，普通部署不会触发。
>
> 🐳 **hf_edition 的启动差异**：默认不启动桌面（`DISABLE_DESKTOP=1`），改为启动 Xvfb + Caddy，由 7860 端口反代 OpenClaw 控制台；`PRO_MODE=1` 时额外启动在线终端与在线文件管理；设置 `DISABLE_DESKTOP=0` 则切换为主镜像同款桌面流程。

---

## 📜 更新日志（最近）

### 2026-10-11

- 🧱 使用 Agent 对容器启动脚本进行工程化重构，能力拆分至 `/bz/lib/*`，启动更健壮、更易维护
- 🤖 新增内置 [Pi Agent](https://pi.dev/)（桌面图标一键启动）
- 📤 新增 [croc](https://getcroc.com/) 命令，方便不同电脑之间互传文件
- ⬆️ OpenClaw 升级至 2026.10.1

> 完整更新历史见 [GitHub 提交记录](https://github.com/TunMax/openclaw_computer/commits/master)。

---

## 🔗 相关链接

| 资源 | 地址 |
| --- | --- |
| OpenClaw 官方中文文档 | https://docs.openclaw.ai/zh-CN |
| ModelScope 创空间（推荐部署） | https://www.modelscope.cn/studios/BrianZhou/openclaw_computer |
| GitHub 仓库 | https://github.com/TunMax/openclaw_computer |
| Pi Agent | https://pi.dev/ |
| croc | https://getcroc.com/ |
| 中科院数据胶囊（免费 20GB S3/WebDAV） | https://data.cstcloud.cn |
