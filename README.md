# openclaw_computer

一个预装 OpenClaw 并具有桌面环境的 Linux 容器，适配 ModelScope、HuggingFace 等免费容器部署服务，通过浏览器即可在安全的隔离环境下畅玩 OpenClaw

## 通过本项目，你将获得：
- 💻 一台硬件配置至少为2核/16GB内存的 Linux 云电脑（在 ModelScope/HuggingFace 开源社区部署时）
- ✨ 具有类 Windows 桌面的系统操作环境，预装 Chrome 浏览器 / 中文拼音输入法，轻松易上手
- 🚀 开箱即用的 OpenClaw，默认配置 ModelScope 免费模型推理后端，提供密钥即可畅玩
- 🧪 在安全的隔离环境中尽情体验 OpenClaw
- 🔄 OpenClaw 配置文件自动备份/恢复

## 运行容器（ModelScope/HuggingFace Spaces）

#### ModelScope 部署教程：
- [📝 文字版（点击查看）](https://mp.weixin.qq.com/s/gAQs3Zl9ohkcSFmQcd-Z-Q)
- [🎬 视频版（点击查看）](https://www.bilibili.com/video/BV1HQwtzuEmw)
- 切换使用 **QwenPaw 版镜像**：
    1. 参照上述文字/视频教程完成部署
    2. 部署后，编辑“空间文件”下的`Dockerfile`文件，将首行代码`FROM ghcr.io/tunmax/openclaw_computer:latest`修改为`FROM ghcr.io/tunmax/openclaw_computer:qwenpaw_latest`，然后在页面底部点击“提交修改”
    3. 最后，在“设置”中点击“深度重启”即可
- 切换使用 **Hermes 版镜像**：
    1. 操作同 **QwenPaw 版镜像** 教程，仅需将`Dockerfile`文件首行最后的`:latest`改为`:hermes_latest`


#### HuggingFace 部署教程：
1. 在 Spaces 仓库目录下添加 Dockerfile 文件，内容参考本仓库的 Dockerfile 文件，但首行代码需修改为 `FROM ghcr.io/tunmax/openclaw_computer:hf_edition`
2. 在“设置”中点击“New secret”按钮创建 `MODELSCOPE_API_KEY` 环境变量，最后点击“Factory rebuild”按钮运行部署即可
3. （可选）将 Bucket 挂载在 `/mnt/workspace` 路径下可激活本地自动备份/恢复特性；设置环境变量 `PRO_MODE` 的值为 `1` 可启动专业模式，容器会额外启动在线终端和在线文件管理服务，方便排查问题

## 运行容器（本地环境）

```bash
docker run -d \
  -p 7860:7860 \
  -e ROOT_PASSWD=123456 \
  -e MODELSCOPE_API_KEY=your_api_key_here \
  ghcr.io/tunmax/openclaw_computer:latest /entrypoint.sh
```
- 激活自动备份/恢复特性：`docker run ... -v ./backups:/mnt/workspace ...`
- 使用 QwenPaw 版本：`docker run ... ghcr.io/tunmax/openclaw_computer:qwenpaw_latest`
- 使用 Hermes 版本：`docker run ... ghcr.io/tunmax/openclaw_computer:hermes_latest`

#### 💡 重要提醒
在开源社区部署本容器时，请勿启动内网穿透相关服务，根据有关反馈和真实案例，HuggingFace Spaces 具备检测容器内是否运行内网穿透服务的能力，一旦检测到此类情况，容器将会被立即删除，相关账号也会面临被封禁的风险。对于 ModelScope Spaces 也请勿运行内网穿透相关服务。本容器仅用于 OpenClaw 的体验。

## 容器特性介绍
1. 容器支持自动备份/恢复 OpenClaw 配置及部分预定义文件夹，具体包括：OpenClaw 配置目录（`/root/.openclaw`）、电脑桌面目录（`/root/Desktop`）、Codex 配置目录（`/root/.codex`）、Claude Code 配置目录（`/root/.claude`）、用户自定义启动脚本目录（`/root/bz-startup`）、zsh 历史记录文件（`/root/.zsh_history`）
    1. 在 ModelScope 部署时，容器默认启用自动备份/恢复特性，相关备份内容会实时自动同步到 `/mnt/workspace` 目录下（该路径是 ModelScope 特供的持久化存储目录），容器重启时自动从此目录下读取并恢复相关备份文件。但需要注意，同一账号下的不同创空间的 `/mnt/workspace` 目录内容并不相通，所以自动备份/恢复功能的应用范围仅限该创空间自身。
    2. 容器还提供利用 **S3/WebDAV 远程存储** 的通用自动备份/恢复特性，实现在 ModelScope、HuggingFace 或本地部署时 OpenClaw 的配置均能无缝同步衔接，使用该特性时需要设置 `S3_XXX`/`WEBDAV_XXX` 相关环境变量，具体见下文的环境变量配置。如果你还没有 S3/WebDAV 远程存储空间，推荐使用中国科学院提供的一项云存储服务「数据胶囊」（[https://data.cstcloud.cn](https://data.cstcloud.cn)）,实名认证后即可获得一个 20GB 的免费存储空间，并支持 S3/WebDAV 协议的访问。
2. 容器支持自定义启动脚本，便于在重启时拉起/配置相关服务，相关脚本代码需写在 `/root/bz-startup/main.sh` 文件中

## 环境变量配置

### 基础配置

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `ROOT_PASSWD` | 否 | `123456` | root 用户密码，长时间未使用系统自动锁屏时需输入此密码解锁 |
| `MODELSCOPE_API_KEY` | 否 | `not_set_yet` | ModelScope API 密钥，用于 OpenClaw 模型服务，未设置时其将无法正常工作 |

### 进阶配置

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `VNC_PASSWD` | 否 | `无` | VNC连接密码，当该值被设置时，容器启动后需要输入此密码才能进入桌面 |
| `SKIP_RESTORE` | 否 | `0` | 当该值设置为 `1` 时，容器将以纯净模式启动。在此模式下，容器启动时不会自动恢复 OpenClaw 历史配置、不会启用相关目录的自动备份功能以及停止执行用户自定义的启动脚本 |
| `KEEP_ORIGINAL_CONF` | 否 | `1` | 容器启动时默认会复制一份镜像自带的 OpenClaw 配置至 `/root/.openclaw_origin` 路径下，便于在 OpenClaw 出现问题时切换回原版配置或与原版配置做对比定位问题 |
| `PRO_MODE` | 否 | `0` | 该变量仅在 HuggingFace 专属镜像上可用。当该值设置为 `1` 时，容器会启动一个在线命令终端，方便在 OpenClaw 进程崩掉后进行排查和恢复，访问地址为：`https://<用户名-空间名>.hf.space/bzshell`，容器还会启动一个在线文件管理页面，访问地址为：`https://<用户名-空间名>.hf.space/bzfiles` |

### 通用自动备份/恢复配置
#### S3 远程存储
| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `S3_BUCKET` | 否 | `无` | S3 远程存储的桶名 Bucket。当该值非空时，容器将启用 S3 远程存储的通用自动备份/恢复特性 |
| `S3_KEY_ID` | 否 | `无` | S3 远程存储的 AccessKey ID |
| `S3_ACCESS_KEY` | 否 | `无` | S3 远程存储的 AccessKey Secret |
| `S3_ENDPOINT` | 否 | `https://s3.cstcloud.cn` | S3 远程存储的接入点 Endpoint，默认值是中国科技院[「数据胶囊」](https://data.cstcloud.cn)服务的 S3 协议接入点（相关链接：[获取中科院免费 20GB S3 云存储空间教程](https://mp.weixin.qq.com/s/JrR6hc07boc_rgP__cL4-w)） |
| `S3_BACKUP_PATH` | 否 | `backups/data.tar.gz` | S3 远程存储的备份路径，设置不同备份路径可以区分备份版本，并选择从指定备份版本中恢复配置。例如，可设置：`backups/data_version_1.tar.gz`、`user1/data.tar.gz`、`user2/data.tar.gz` |
| `BACKUP_ENC_PASS` | 否 | `无` | 备份文件加密密码，当该值被设置时，备份文件传输到远程网络存储前会先被加密，实现端到端加密（E2E）效果 |

#### WebDAV 远程存储
| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `WEBDAV_URL` | 否 | `无` | WebDAV 服务地址。当该值非空时，容器将启用 WebDAV 远程存储的通用自动备份/恢复特性 |
| `WEBDAV_USER` | 否 | `无` | WebDAV 服务用户名 |
| `WEBDAV_PASSWD` | 否 | `无` | WebDAV 服务密码 |
| `WEBDAV_CLIENT_UA` | 否 | `Zotero/8.0` | 连接 WebDAV 服务的 UA 标头，默认值是中国科技院[「数据胶囊」](https://data.cstcloud.cn)服务限定允许接入的客户端 UA 标头 |
| `WEBDAV_BACKUP_PATH` | 否 | `backups/data.tar.gz` | WebDAV 远程存储的备份路径，设置不同备份路径可以区分备份版本，并选择从指定备份版本中恢复配置。例如，可设置：`backups/data_version_1.tar.gz`、`user1/data.tar.gz`、`user2/data.tar.gz` |
| `BACKUP_ENC_PASS` | 否 | `无` | 备份文件加密密码，当该值被设置时，备份文件传输到远程网络存储前会先被加密，实现端到端加密（E2E）效果 |


## 使用技巧

- 按 `Ctrl+Shift` 组合键切换中英文输入法
- 启动后屏幕左侧工具栏可调出剪贴板，在上面输入或粘贴文字后，即可在容器内粘贴

## FAQ
1. **为什么有时候 ModelScope 的创空间使用起来非常卡？**  
根据近期的观察，早上时段流畅，晚上时段则易卡顿。因为 ModelScope/HuggingFace 提供的免费 2核16GB 配置硬件是没有 SLA 协议的，即服务级别协议（Service Level Agreement，一般商业付费服务才有，内容主要包括硬件可用性、网络响应性以及发生故障时的修复时限等内容）。ModelScope 提供免费层级的配置应该是根据阿里云闲置资源的实际情况来提供，当高峰期时闲置资源少，就会变卡，低峰期闲置资源多，所以流畅。使用 ModelScope/HuggingFace 付费硬件配置时，因为有 SLA 协议，所以应该是一直流畅的。
2. **openclaw 配置错误容器无限重启无法启动怎么办？**  
设置环境变量 `SKIP_RESTORE=1`，此时容器将以纯净模式启动，不会自动恢复 OpenClaw 历史配置、不会启用相关目录的自动备份功能以及停止执行用户自定义的启动脚本。
3. **为什么 ModelScope（国际版）选择深度重启后镜像还是旧的版本？**  
这似乎是国际版的 bug，需要删除创空间后重新创建，才会拉取最新的容器镜像。
4. **如何设置自动备份/恢复 Chrome 浏览器的书签、浏览历史等数据？**  
由于浏览器数据占用空间比较大，备份及远程传输时可能会很慢，所以没有列为默认备份/恢复目录。但可以通过自定义启动脚本的功能，实现浏览器数据的备份/恢复。以 ModelScope 部署为例，修改脚本文件（/root/bz-startup/main.sh），使其内容如下即可：  
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

## 更新日志

**升级操作说明**：ModelScope 已经部署容器的用户，需要在创空间“设置”处点击“深度重启”，然后才会自动拉取最新的容器镜像并部署。

#### 2026-10-02
1. OpenClaw 升级至 2026.9.7 版本
2. NodeJS 版本升级至 v24.21.0

#### 2026-07-17
1. OpenClaw 升级至 2026.7.1 版本

#### 2026-06-16
1. OpenClaw 升级至 2026.6.6 版本

#### 2026-06-04
1. OpenClaw 升级至 2026.6.1 版本
2. 默认开启工作板（workboard）功能
3. 优化 konsole 终端的剪贴板同步逻辑，操作更便捷

#### 2026-06-02
1. QwenPaw 升级至 1.1.10 版本
2. Hermes 升级至 0.15.2 版本

#### 2026-05-31
1. OpenClaw 升级至 2026.5.28 版本

#### 2026-05-22
1. OpenClaw 升级至 2026.5.20 版本
2. 首选推理模型切换为 Ring-2.6-1T

#### 2026-05-21
1. OpenClaw 升级至 2026.5.19 版本
2. 删除 AGENTS.md/MEMORY.md 中关于规范 openclaw 重启行为的规则，目前 openclaw 自身已能完成优雅重启
3. 修复 Konsole 终端执行 `openclaw doctor` 等命令时，内容有时会被截断无法完整显示的问题

#### 2026-05-19
1. OpenClaw 升级至 2026.5.18 版本
2. 修复 HuggingFace 专属镜像在线终端发送 `Ctrl+C` 终止命令时无效的问题
3. 在使用云端进行 openclaw 配置恢复时，如果检测到恢复不成功，容器将终止运行并提示用户有关信息

#### 2026-05-18
1. HuggingFace 专属镜像专业模式下新增在线文件管理功能，访问地址为：`https://<你的空间真实url>/bzfiles`

#### 2026-05-17
1. HuggingFace 专属镜像新增专业模式，设置环境变量 `PRO_MODE` 为 `1` 时启用，该模式下会启动一个在线终端，访问地址为：`https://<你的空间真实url>/bzshell`

#### 2026-05-16
1. 新增在 HuggingFace 部署的专属镜像，docker tag 标识为 `hf_edition`

#### 2026-05-15
OpenClaw 版镜像：
1. 升级至最新 2026.5.12 版本
2. 优化中文输入法，提升输入体验
3. apt/npm/uv 相关包升级至最新

QwenPaw 版镜像：升级至最新 1.1.7 版本，同步 OpenClaw 版优化

Hermes 版镜像：升级至最新 0.13.0 版本，同步 OpenClaw 版优化

#### 2026-05-08

OpenClaw 版镜像：
1. 升级至最新 2026.5.7 版本

#### 2026-05-07

OpenClaw 版镜像：
1. memory_core 配置的本地 embedding 模型切换为 nomic-embed-text-v1.5
2. 升级至最新 2026.5.6 版本

QwenPaw 版镜像：
1. 升级至最新 1.1.5.post2 版本

#### 2026-05-06

OpenClaw 版镜像：
1. 为 memory_core 配置本地 embedding 模型（bge-small-zh-v1.5），并默认开启 OpenClaw “梦境”功能
2. 升级至最新 2026.5.4 版本

#### 2026-05-01

QwenPaw 版镜像：
1. 升级至最新 1.1.5.post1 版本

Hermes 版镜像：
1. 升级至最新 0.12.0 版本

OpenClaw 版镜像：
- ⚠️ 因最新 2026.4.29 版本存在严重 gateway 阻塞 bug，故暂停升级

#### 2026-04-25
OpenClaw 版镜像：
1. 升级至最新 2026.4.23 版本
2. 默认模型修改为 Qwen3.5-122B-A10B，以提供多模态输入支持

QwenPaw 版镜像：
1. 升级至最新 1.1.4.post1 版本
2. 默认模型修改为 Qwen3.5-122B-A10B，以提供多模态输入支持

Hermes 版镜像：
1. 升级至最新 0.11.0 版本
2. 默认模型修改为 Qwen3.5-122B-A10B，以提供多模态输入支持
3. 修复魔搭社区深度重启拉取新镜像后，Hermes 功能升级不完整问题

#### 2026-04-23
1. OpenClaw 升级至最新 2026.4.21 版本
2. Chrome 浏览器升级至最新 147.0.7727.116 版本

#### 2026-04-22
1. OpenClaw 升级至最新 2026.4.20 版本

#### 2026-04-18
1. OpenClaw 升级至最新 2026.4.15 版本
2. QwenPaw 版镜像：升级至最新 1.1.2 版本
3. Hermes 版镜像：升级至最新 0.10.0 版本

#### 2026-04-15
1. OpenClaw 升级至最新 2026.4.14 版本
2. QwenPaw 版镜像：升级至最新 1.1.1 版本

#### 2026-04-14
1. Hermes 版镜像：升级至最新 0.9.0 版本

#### 2026-04-13
1. 新增 QwenPaw 版镜像，docker tag 标识为 `qwenpaw_latest`（备注：官方已将 CoPaw 正式更名为 QwenPaw）
2. 优化 Hermes 版镜像，自动备份时忽略 node_modules 文件夹

#### 2026-04-12
1. 新增 Hermes 版镜像，docker tag 标识为 `hermes_latest`
2. OpenClaw 升级至最新 2026.4.11 版本
3. CoPaw 版：同步 OpenClaw 版 260411 的更新

#### 2026-04-11
1. OpenClaw 升级至最新 2026.4.10 版本
2. Chrome 浏览器的默认搜索引擎设置为 Bing

#### 2026-04-10
1. CoPaw 版：升级至最新 1.0.2 版本、同步 OpenClaw 版 260409 的更新

#### 2026-04-09
1. OpenClaw 升级至最新 2026.4.9 版本
2. Chrome 浏览器升级至最新 147.0.7727.55 版本

#### 2026-04-06
1. OpenClaw 升级至最新 2026.4.5 版本
2. CoPaw 版：升级至最新 1.0.1 版本

#### 2026-04-03
1. OpenClaw 升级至最新 2026.4.2 版本

#### 2026-04-02
1. 通过远程网络存储备份时，新增支持 E2E 加密功能（设置 `BACKUP_ENC_PASS` 环境变量开启）
2. OpenClaw 升级至最新 2026.4.1 版本
3. CoPaw 版：升级至最新 1.0.0.post3 版本

#### 2026-04-01
1. OpenClaw 升级至最新 2026.3.31 版本
2. Chrome 浏览器升级至最新 146.0.7680.177 版本
3. CoPaw 版：升级至最新 1.0.0.post2 版本

#### 2026-03-31
1. CoPaw 版：升级至最新 1.0.0 版本

#### 2026-03-29
1. OpenClaw 升级至最新 2026.3.28 版本

#### 2026-03-26
1. OpenClaw 升级至最新 2026.3.24 版本
2. CoPaw 版：升级至最新 0.2.0.post1 版本

#### 2026-03-25
1. OpenClaw 升级至最新 2026.3.23-2 版本
2. CoPaw 版：升级至最新 0.2.0 版本、同步 OpenClaw 版 260324 的更新

#### 2026-03-24
1. 支持 WebDAV 远程存储的通用自动备份/恢复特性
2. 支持自定义配置 VNC 连接密码
3. 内置应用新增 Ark 压缩包管理工具
4. OpenClaw 升级至最新 2026.3.23 版本
5. Chrome 浏览器升级至最新 146.0.7680.164 版本

#### 2026-03-22
1. 修复 `openclaw.json` 存在语法错误导致插件无法正常安装的问题
2. Chrome 浏览器升级至最新 146.0.7680.153 版本
3. CoPaw 版：同步 OpenClaw 版 260321-260322 的更新

#### 2026-03-21
1. 支持 S3 远程存储的通用自动备份/恢复特性
2. 优化实时自动备份执行逻辑

#### 2026-03-16
1. 修复 OpenClaw 自我重启时总提示需要先升级 node 版本的问题
2. 为方便使用，默认关闭自动锁屏的功能
3. CoPaw 版：同步 OpenClaw 版 260314~260316 的所有更新，同时解决在 ModelScope（国际版）重启容器后无法恢复 CoPaw 配置的问题。

#### 2026-03-15
1. 新增 `SKIP_RESTORE` 环境变量，其值设置为 1 时，容器启动时不会自动恢复 OpenClaw 历史配置，同时停用相关配置目录的自动备份功能和禁止执行用户自定义的启动脚本
2. OpenClaw 升级至最新 2026.3.13 版本
3. Chrome 浏览器升级至最新 146.0.7680.80 版本

#### 2026-03-14
1. 优化容器启动流程，避免因 openclaw 配置错误导致容器关闭，进而无法进入桌面环境排查问题

#### 2026-03-13
1. OpenClaw 升级至最新 2026.3.12 版本
2. 新增 copaw_computer 版本，docker 镜像使用 ghcr.io/tunmax/openclaw_computer:copaw_latest

#### 2026-03-12
1. 解决手动点击网页文件时，Chrome 浏览器无法正常调起的问题
2. 优化 noVNC 视窗显示，默认自动缩放系统画面至用户浏览器视窗大小

#### 2026-03-11
1. 降低 OpenClaw 在执行自我重启操作时的失败概率
2. 解决深度重启创空间后，浏览器可能无法正常连接 openclaw web-ui，需手动在网关 url 后面添加 `&token=xxx` 的问题
3. Chrome 浏览器升级至最新 146 版本

#### 2026-03-10
1. 新增支持自定义启动脚本，便于在容器休眠/重启后自动恢复指定进程，相关脚本代码需写在 `/root/bz-startup/main.sh` 文件中
2. 新增支持 ModelScope 容器自动实时备份/重启后自动恢复的路径：`/root/bz-startup`, `/root/.codex`, `/root/.claude`
3. 修复 ModelScope 用户名称加上创空间英文名称长度超过27个字符时可能导致 OpenClaw 启动失败的问题

#### 2026-03-09
1. 将 npm 仓库官方源更改为国内源（registry.npmmirror.com），npm 下载安装模块速度可拉满
2. OpenClaw 升级至最新 2026.3.8 版本
3. 进一步压缩减小了镜像体积

#### 2026-03-08
1. 现已支持 ModelScope 容器在休眠/重启（含深度重启）后自动恢复 OpenClaw 的配置信息（目录：/root/.openclaw）,不用担心重启后配置可能丢失的问题。同时，以下目录及文件也会自动恢复：桌面目录（/root/Desktop）、zsh 历史记录文件（/root/.zsh_history）  
**实现原理**：系统会利用 `inotifywait` 命令实时监控上述文件夹及文件的变化，当发生变化时，会立即使用 `rsync` 命令将最新版本的文件同步到 ModelScope 的 `/mnt/workspace` 持久化存储路径下；而在系统刚启动时，会检查 `/mnt/workspace` 目录下是否存在可恢复的文件夹及文件，如果存在则会执行恢复操作，恢复完成后才会启动 openclaw gateway
2. OpenClaw 升级至最新 2026.3.7 版本
3. 压缩减小了镜像体积

Made with ❤️ by 百泽牧
