# openclaw_computer

一个预装 OpenClaw 并具有桌面环境的 Linux 容器，适配 ModelScope、HuggingFace 等免费容器部署服务，通过浏览器即可在安全环境下畅玩体验 OpenClaw

## 通过本项目，你将获得：
- 💻 一台硬件配置至少为2核/16GB内存的 Linux 云电脑，硬件由 ModelScope/HuggingFace 免费提供
- ✨ 具有类 Windows 桌面的系统操作环境，预装 Chrome 浏览器 / 中文拼音输入法，轻松易上手
- 🚀 开箱即用的 OpenClaw，默认配置 ModelScope 免费模型推理后端，提供密钥即可畅玩

## 重要提醒
使用本容器时，请勿部署内网穿透相关服务，根据有关反馈和真实案例，HuggingFace Spaces 具备检测容器内是否运行内网穿透服务的能力，一旦检测到此类情况，容器将会被立即删除，相关账号也会面临被封禁的风险。对于 ModelScope Spaces 也请勿运行内网穿透相关服务。本容器仅用于 OpenClaw 的体验。

## 运行容器（ModelScope/HuggingFace Spaces）

在 Spaces 仓库目录下添加 Dockerfile 文件，内容和本仓库中的 Dockerfile 文件保持一致，然后在“设置”中添加 `ROOT_PASSWD` 和 `MODELSCOPE_API_KEY` 两个环境变量，最后点击重启容器即可开始部署。

ModelScope API 密钥获取教程参见：[https://modelscope.cn/docs/accounts/token](https://modelscope.cn/docs/accounts/token)

## 运行容器（本地）

```bash
docker run -d \
  -p 7860:7860 \
  -e ROOT_PASSWD=123456 \
  -e MODELSCOPE_API_KEY=your_api_key_here \
  tunmax/openclaw_computer:latest
```

## 环境变量配置

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `ROOT_PASSWD` | 否 | `123456` | root 用户密码，长时间未使用系统自动锁屏时需输入此密码解锁 |
| `MODELSCOPE_API_KEY` | 否 | `not_set_yet` | ModelScope API 密钥，用于 OpenClaw 模型服务，未设置时其将无法正常工作 |


## 帮助信息

- 支持自定义启动脚本（目前仅限 ModelScope），相关代码需写在 `/root/bz-startup/main.sh` 文件中
- 按 `Ctrl+Shift` 组合键切换中英文输入法
- 启动后屏幕左侧工具栏可调出剪贴板，可在上面输入或粘贴文字，然后在容器内可以直接粘贴

## 更新日志

**升级操作说明**：ModelScope 已经部署容器的用户，需要在创空间“设置”处点击“深度重启”，然后才会自动拉取最新的容器镜像并部署。

#### 2026-03-08
1. 现已支持 ModelScope 容器在休眠/重启（含深度重启）后自动恢复 OpenClaw 的配置信息（目录：/root/.openclaw）,不用担心重启后配置可能丢失的问题。同时，以下目录及文件也会自动恢复：桌面目录（/root/Desktop）、zsh 历史记录文件（/root/.zsh_history）  
**实现原理**：系统会利用 `inotifywait` 命令实时监控上述文件夹及文件的变化，当发生变化时，会立即使用 `rsync` 命令将最新版本的文件同步到 ModelScope 的 `/mnt/workspace` 持久化储存路径下；而在系统刚启动时，会检查 `/mnt/workspace` 目录下是否存在可恢复的文件夹及文件，如果存在则会执行恢复操作，恢复完成后才会启动 openclaw gateway。
2. OpenClaw 升级到最新的 2026.3.7 版本
3. 压缩减小了镜像体积

#### 2026-03-09
1. 将 npm 仓库官方源更改为国内源（registry.npmmirror.com），npm 下载安装模块速度可拉满
2. OpenClaw 升级到最新的 2026.3.8 版本
3. 进一步压缩减小了镜像体积

#### 2026-03-10
1. 新增支持自定义启动脚本，便于在容器休眠/重启后自动恢复指定进程，相关脚本代码需写在 `/root/bz-startup/main.sh` 文件中。
2. 新增支持 ModelScope 容器自动实时备份/重启后自动恢复的路径：`/root/bz-startup`, `/root/.codex`, `/root/.claude`
3. 修复 ModelScope 用户名称加上创空间英文名称长度超过27个字符时可能导致 OpenClaw 启动失败的问题。

Made with ❤️ by 百泽匠人
