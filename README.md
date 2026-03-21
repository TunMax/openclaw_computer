# openclaw_computer

一个预装 OpenClaw 并具有桌面环境的 Linux 容器，适配 ModelScope、HuggingFace 等免费容器部署服务，通过浏览器即可在安全的隔离环境下玩转 OpenClaw

## 通过本项目，你将获得：
- 💻 一台硬件配置至少为2核/16GB内存的 Linux 云电脑（在 ModelScope/HuggingFace 开源社区部署时）
- ✨ 具有类 Windows 桌面的系统操作环境，预装 Chrome 浏览器 / 中文拼音输入法，轻松易上手
- 🚀 开箱即用的 OpenClaw，默认配置 ModelScope 免费模型推理后端，提供密钥即可畅玩
- 🧪 在安全的隔离环境中尽情体验 OpenClaw
- 🔄 OpenClaw 配置文件自动备份/恢复

## 运行容器（ModelScope/HuggingFace Spaces）

在 Spaces 仓库目录下添加 Dockerfile 文件，内容和本仓库中的文件一致，然后在“设置”中添加 `ROOT_PASSWD` 和 `MODELSCOPE_API_KEY` 两个环境变量，最后点击重启容器即可开始部署。

### ！！！重要提醒
使用本容器时，请勿部署内网穿透相关服务，根据有关反馈和真实案例，HuggingFace Spaces 具备检测容器内是否运行内网穿透服务的能力，一旦检测到此类情况，容器将会被立即删除，相关账号也会面临被封禁的风险。对于 ModelScope Spaces 也请勿运行内网穿透相关服务。本容器仅用于 OpenClaw 的体验。

## 运行容器（本地环境）

```bash
docker run -d \
  -p 7860:7860 \
  -e ROOT_PASSWD=123456 \
  -e MODELSCOPE_API_KEY=your_api_key_here \
  ghcr.io/tunmax/openclaw_computer:latest
```
2026-03-13：新增 copaw 版本，docker 镜像请使用：ghcr.io/tunmax/openclaw_computer:copaw_latest

## 容器特性介绍
1. 容器支持自动备份/恢复 OpenClaw 配置及部分预定义文件夹，具体包括：OpenClaw 配置目录（`/root/.openclaw`）、电脑桌面目录（`/root/Desktop`）、Codex 配置目录（`/root/.codex`）、Claude Code 配置目录（`/root/.claude`）、用户自定义启动脚本目录（`/root/bz-startup`）、zsh 历史记录文件（`/root/.zsh_history`）
    1. 在 ModelScope 部署时，容器默认启用自动备份/恢复特性，相关备份内容会实时自动同步到 `/mnt/workspace` 目录下（该路径是 ModelScope 特供的持久化储存目录），容器重启时自动从此目录下读取并恢复相关备份文件。但需要注意，同一账号下的不同创空间的 `/mnt/workspace` 目录内容并不相通，所以自动备份/恢复功能的应用范围仅限该创空间自身。
    2. 容器还提供利用 **S3 远程储存** 的通用自动备份/恢复特性，使得在 ModelScope、HuggingFace 或本地部署时 OpenClaw 的配置均能无缝同步衔接，使用该特性时需要设置 `S3_XXX` 相关环境变量，具体见下文的环境变量配置。如果你还没有 S3 远程储存空间，推荐使用中国科学院提供的一项云存储服务「数据胶囊」（[https://data.cstcloud.cn](https://data.cstcloud.cn)）,实名认证后即可获得一个 20GB 的免费储存空间，并支持 S3/WebDAV 协议的访问。
2. 容器支持自定义启动脚本，便于在重启时拉起/配置相关服务，相关脚本代码需写在 `/root/bz-startup/main.sh` 文件中

## 环境变量配置

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `ROOT_PASSWD` | 否 | `123456` | root 用户密码，长时间未使用系统自动锁屏时需输入此密码解锁 |
| `MODELSCOPE_API_KEY` | 否 | `not_set_yet` | ModelScope API 密钥，用于 OpenClaw 模型服务，未设置时其将无法正常工作 |
| `SKIP_RESTORE` | 否 | `0` | 当该值设置为 `1` 时，容器将以纯净模式启动。在此模式下，容器启动时不会自动恢复 OpenClaw 历史配置、不会启用相关目录的自动备份功能以及停止执行用户自定义的启动脚本 |
| `S3_BUCKET` | 否 | `空值` | S3 远程储存的桶名 Bucket。当该值非空时，容器将启用 S3 远程储存的通用自动备份/恢复特性 |
| `S3_KEY_ID` | 否 | `空值` | S3 远程储存的 AccessKey ID |
| `S3_ACCESS_KEY` | 否 | `空值` | S3 远程储存的 AccessKey Secret |
| `S3_ENDPOINT` | 否 | `https://s3.cstcloud.cn` | S3 远程储存的接入点 Endpoint，默认值是中国科技院[「数据胶囊」](https://data.cstcloud.cn)服务的 S3 协议接入点 |
| `S3_BACKUP_PATH` | 否 | `backups/data.tar.gz` | S3 远程储存的备份路径，设置不同备份路径可以区分备份版本，并选择从指定备份版本中恢复配置。例如，可设置：`backups/data_version_1.tar.gz`、`user1/data.tar.gz`、`user2/data.tar.gz` |


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

## 更新日志

**升级操作说明**：ModelScope 已经部署容器的用户，需要在创空间“设置”处点击“深度重启”，然后才会自动拉取最新的容器镜像并部署。

#### 2026-03-21
1. 支持 S3 远程储存的通用自动备份/恢复特性
2. 优化实时自动备份执行逻辑

#### 2026-03-16
1. 修复 OpenClaw 自我重启时总提示需要先升级 node 版本的问题
2. 为方便使用，默认关闭自动锁屏的功能
3. CoPaw 版：同步 OpenClaw 版 260314~260316 的所有更新，同时解决在 ModelScope（国际版）重启容器后无法恢复 CoPaw 配置的问题。

#### 2026-03-15
1. 新增 `SKIP_RESTORE` 环境变量，其值设置为 1 时，容器启动时不会自动恢复 OpenClaw 历史配置，同时停用相关配置目录的自动备份功能和禁止执行用户自定义的启动脚本
2. OpenClaw 升级到最新的 2026.3.13 版本
3. Chrome 浏览器升级至最新的 146.0.7680.80 版本

#### 2026-03-14
1. 优化容器启动流程，避免因 openclaw 配置错误导致容器关闭，进而无法进入桌面环境排查问题

#### 2026-03-13
1. OpenClaw 升级到最新的 2026.3.12 版本
2. 新增 copaw_computer 版本，docker 镜像使用 ghcr.io/tunmax/openclaw_computer:copaw_latest

#### 2026-03-12
1. 解决手动点击网页文件时，Chrome 浏览器无法正常调起的问题
2. 优化 noVNC 视窗显示，默认自动缩放系统画面至用户浏览器视窗大小

#### 2026-03-11
1. 降低 OpenClaw 在执行自我重启操作时的失败概率
2. 解决深度重启创空间后，浏览器可能无法正常连接 openclaw web-ui，需手动在网关 url 后面添加 `&token=xxx` 的问题
3. Chrome 浏览器升级至最新的 146 版本

#### 2026-03-10
1. 新增支持自定义启动脚本，便于在容器休眠/重启后自动恢复指定进程，相关脚本代码需写在 `/root/bz-startup/main.sh` 文件中
2. 新增支持 ModelScope 容器自动实时备份/重启后自动恢复的路径：`/root/bz-startup`, `/root/.codex`, `/root/.claude`
3. 修复 ModelScope 用户名称加上创空间英文名称长度超过27个字符时可能导致 OpenClaw 启动失败的问题

#### 2026-03-09
1. 将 npm 仓库官方源更改为国内源（registry.npmmirror.com），npm 下载安装模块速度可拉满
2. OpenClaw 升级到最新的 2026.3.8 版本
3. 进一步压缩减小了镜像体积

#### 2026-03-08
1. 现已支持 ModelScope 容器在休眠/重启（含深度重启）后自动恢复 OpenClaw 的配置信息（目录：/root/.openclaw）,不用担心重启后配置可能丢失的问题。同时，以下目录及文件也会自动恢复：桌面目录（/root/Desktop）、zsh 历史记录文件（/root/.zsh_history）  
**实现原理**：系统会利用 `inotifywait` 命令实时监控上述文件夹及文件的变化，当发生变化时，会立即使用 `rsync` 命令将最新版本的文件同步到 ModelScope 的 `/mnt/workspace` 持久化储存路径下；而在系统刚启动时，会检查 `/mnt/workspace` 目录下是否存在可恢复的文件夹及文件，如果存在则会执行恢复操作，恢复完成后才会启动 openclaw gateway
2. OpenClaw 升级到最新的 2026.3.7 版本
3. 压缩减小了镜像体积

Made with ❤️ by 百泽牧
