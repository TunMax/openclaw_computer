FROM ghcr.io/tunmax/openclaw_computer:latest

# 环境变量
ENV TZ=Asia/Shanghai \
    DISPLAY=:1 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24

# 复制入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露 noVNC 端口
EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
