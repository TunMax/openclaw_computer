#!/bin/bash

start_services() {
    echo "[*] 启动服务..."

    export USER="${USER:-root}"
    export HOME="${HOME:-/root}"
    export DISPLAY=":1"
    export DEBIAN_FRONTEND=noninteractive
    export LANG=zh_CN.UTF-8
    export LC_ALL=zh_CN.UTF-8
    export LANGUAGE=zh_CN:zh

    VNC_DISPLAY=":1"
    VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
    VNC_DEPTH="${VNC_DEPTH:-24}"
    VNC_PORT=5901
    NOVNC_PORT=7860

    mkdir -p "${HOME}/.vnc"

    # ── xstartup：携带性能环境变量启动 KDE ──
    cat > "${HOME}/.vnc/xstartup" <<'XSTARTUP'
#!/bin/bash
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export DISPLAY=:1

# 强制禁用 KWin 合成器（环境变量层面双重保险）
export KWIN_COMPOSE=N
# 禁用 Qt 动画
export QT_QUICK_CONTROLS_STYLE=Fusion
export PLASMA_USE_QT_SCALING=0

# ── 输入法环境变量（必须在 dbus 之前导出）──
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx

# ── 启动 DBus session（startplasma-x11 依赖它打开任何窗口）──
# TigerVNC 不会自动创建 dbus session，必须手动启动
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
    export DBUS_SESSION_BUS_ADDRESS
    export DBUS_SESSION_BUS_PID
fi

# 把 dbus 地址写入文件，方便后续子进程（Chrome/Fcitx5）继承
echo "DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}" > /tmp/dbus-session.env

# ── 启动 Fcitx5（必须在 KDE 之前启动，否则输入法框架无法注册）──
fcitx5 -d --disable=wayland
sleep 1

# ── 启动 KDE Plasma ──
exec startplasma-x11
XSTARTUP
    chmod +x "${HOME}/.vnc/xstartup"

    # 清理残留锁文件
    vncserver -kill "${VNC_DISPLAY}" 2>/dev/null || true
    rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

    # 启动 TigerVNC，无密码模式
    # SecurityTypes=None 时必须携带 --I-KNOW-THIS-IS-INSECURE
    echo "[*] 启动 TigerVNC on ${VNC_DISPLAY} (${VNC_GEOMETRY})..."
    vncserver "${VNC_DISPLAY}" \
        -geometry "${VNC_GEOMETRY}" \
        -depth "${VNC_DEPTH}" \
        -SecurityTypes None \
        --I-KNOW-THIS-IS-INSECURE \
        -localhost no \
        -fg &

    # 等待 VNC 端口就绪（最多 30s）
    echo "[*] 等待 VNC 服务就绪（端口 ${VNC_PORT}）..."
    for i in $(seq 1 30); do
        if ss -tlnp 2>/dev/null | grep -q ":${VNC_PORT}"; then
            echo "[*] VNC 已就绪"
            break
        fi
        sleep 1
    done

    # 找到 noVNC 静态文件目录
    NOVNC_PATH=""
    for candidate in /usr/share/novnc /opt/novnc /usr/local/share/novnc; do
        if [ -f "${candidate}/vnc.html" ]; then
            NOVNC_PATH="${candidate}"
            break
        fi
    done
    if [ -z "${NOVNC_PATH}" ]; then
        NOVNC_PATH="$(dirname "$(find / -maxdepth 6 -name 'vnc.html' 2>/dev/null | head -1)")"
    fi
    echo "[*] noVNC 路径: ${NOVNC_PATH}"

    # 覆盖 index.html：直接访问 :7860 自动跳转 vnc.html
    cat > "${NOVNC_PATH}/index.html" <<'REDIRECT'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&reconnect=true&reconnect_delay=2000">
<title>KDE Desktop</title>
</head>
<body>
<p>正在跳转到桌面... <a href="vnc.html?autoconnect=true">点击这里</a></p>
</body>
</html>
REDIRECT

    # 启动 websockify（noVNC 代理）
    echo "[*] 启动 noVNC，监听端口 ${NOVNC_PORT}..."
    websockify \
        --web "${NOVNC_PATH}" \
        --heartbeat 30 \
        "0.0.0.0:${NOVNC_PORT}" \
        "localhost:${VNC_PORT}" &

    NOVNC_PID=$!
    echo ""
    echo "============================================"
    echo "  KDE Plasma 桌面已启动！"
    echo "  访问地址: http://<host>:${NOVNC_PORT}"
    echo "  分辨率:   ${VNC_GEOMETRY}"
    echo "  时区:     Asia/Shanghai (UTC+8)"
    echo "  语言:     zh_CN.UTF-8"
    echo "  特效:     已全部禁用（最流畅模式）"
    echo "  输入法:   Fcitx5 拼音（默认中文，Ctrl+Space 切换）"
    echo "  浏览器:   Google Chrome（默认）"
    echo "============================================"

    # 设置 root 默认密码（防止意外锁屏后无法开启）
    echo "root:${ROOT_PASSWD:-123456}" | chpasswd

    # 运行 openclaw gateway
    export MODELSCOPE_API_KEY="${MODELSCOPE_API_KEY:-not_set_yet}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion    
    source "/root/.openclaw/completions/openclaw.bash"  # OpenClaw Completion
    nohup /root/.nvm/versions/node/v24.14.0/bin/openclaw gateway run > /tmp/openclaw_gateway.log &
    # 启动 Chrome 浏览器
    # 等待18789端口就绪后启动Chrome
    timeout=60
    elapsed=0
    while ! netstat -tlnp 2>/dev/null | grep -q ':18789'; do
        sleep 0.5
        elapsed=$((elapsed + 1))
        if [ $elapsed -ge $((timeout * 2)) ]; then
            echo "Timeout: port 18789 not ready after ${timeout}s" >&2
            exit 1
        fi
    done
    # 执行启动
    source /tmp/dbus-session.env 2>/dev/null || true
    XDG_CURRENT_DESKTOP=KDE \
    KDE_FULL_SESSION=true \
    DESKTOP_SESSION=plasma \
    XDG_SESSION_TYPE=x11 \
    GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    INPUT_METHOD=fcitx \
    SDL_IM_MODULE=fcitx \
    DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}" \
    google-chrome-stable \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --test-type \
    http://127.0.0.1:18789 > /dev/null 2>&1 &

    # wait ${NOVNC_PID}
    tail -f /dev/null
}

# ─────────────────────────────────────────────
# 主流程
# ─────────────────────────────────────────────
main() {
    export LANG=zh_CN.UTF-8
    export LC_ALL=zh_CN.UTF-8
    export LANGUAGE=zh_CN:zh
    start_services
}

main "$@"
