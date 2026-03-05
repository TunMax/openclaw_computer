# openclaw_computer

一个预装 OpenClaw 并具有桌面环境的 Docker 容器，同时适配 ModelScope、HuggingFace 等免费容器部署，通过浏览器即可畅玩体验 OpenClaw

## 功能特性

- 🔧 **OpenClaw 预装** - 环境变量设置 MODELSCOPE_API_KEY 就能开始使用
- 🖥️ **KDE Plasma 桌面** - 完整的 Linux 桌面环境
- 🌐 **noVNC 网页访问** - 通过浏览器直接访问桌面，无需客户端
- 🌏 **中文环境** - 默认中文界面，支持 Fcitx5 拼音输入法
- 📦 **Chrome 浏览器** - 预装 Google Chrome

## 运行命令

```bash
docker run -d \
  -p 7860:7860 \
  -e ROOT_PASSWD=123456 \
  -e MODELSCOPE_API_KEY=your_api_key_here \
  --name mypc \
  openclaw_computer:latest
```

## 环境变量配置

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `ROOT_PASSWD` | 否 | `123456` | root 用户密码 |
| `MODELSCOPE_API_KEY` | 否 | `not_set_yet` | ModelScope API 密钥，用于 OpenClaw 服务。密钥获取教程：[https://modelscope.cn/docs/accounts/token](https://modelscope.cn/docs/accounts/token) |


## 帮助信息

- **输入法**：Fcitx5 拼音，`Ctrl+Shift` 切换中英文
