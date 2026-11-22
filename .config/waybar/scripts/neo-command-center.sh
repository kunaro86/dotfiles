#!/bin/bash

# ==============================================================================
# Command Center - 常用维护指令集
# ==============================================================================
# 脚本功能：
# 1. 严格模式执行，保障代码健壮性。
# 2. 启动时检测必要的前置依赖 (kitty、fuzzel)，若缺失则报错。
# 3. 动态环境与命令探测，按需生成菜单选项，不显示当前环境中不可用的功能：
#    - Fluxdown 检测：检测 fluxdown CLI 是否可用，决定是否显示下载选项。
#    - 下载目录：自动创建 ~/Downloads 并作为默认下载位置。
# ==============================================================================

# 启用严格模式：
# -e: 命令执行失败(非0)时立即退出
# -u: 使用未定义变量时报错并退出
# -o pipefail: 管道中任何一个命令失败都会导致整个管道返回失败
set -euo pipefail

# 错误处理与通知函数
report_error() {
    local error_msg="$1"
    echo "错误：$error_msg" >&2
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical -a "Command Center" "指令异常" "$error_msg" || true
    fi
}

# 下载函数：接收下载地址，调用 fluxdown 下载到 ~/Downloads/
# 参数 $1: 下载地址 URL
# 说明：在后台执行下载，结束后通过 mako 通知结果；不阻塞命令中心，也不弹终端窗口。
download_file() {
    local url="$1"
    local download_dir="$HOME/Downloads"

    # 确保下载目录存在
    mkdir -p "$download_dir"

    # 使用 nohup + 子 shell 脱离父进程，避免命令中心退出时下载被中断。
    # 子 shell 内通过位置参数 $1/$2 接收 URL 与下载目录，不依赖父函数的 local 变量。
    # 成功/失败依据 fluxdown 的退出码判断；通知里带上文件名便于确认。
    nohup bash -c '
        url="$1"
        dir="$2"
        if fluxdown add --local --dir "$dir" "$url"; then
            fname=$(basename "${url%%\?*}")
            notify-send -a "Fluxdown" "✔️ 下载完成" "${fname}\n文件已保存至 ${dir}"
        else
            notify-send -a "Fluxdown" -u critical "下载失败" "请检查网络连接或 url 拼写"
        fi
    ' _ "$url" "$download_dir" >/dev/null 2>&1 &
}

# 0. 基础依赖检测 (fuzzel、kitty)
if ! command -v fuzzel >/dev/null 2>&1; then
    report_error "未找到 fuzzel，请先安装。"
    exit 1
fi

if ! command -v kitty >/dev/null 2>&1; then
    report_error "未找到 kitty 终端，请先安装。"
    exit 1
fi

# 声明所有可能用到的选项和执行命令变量，满足 set -u 要求
OPT_DOWNLOAD=""

# 使用数组存储动态生成的选项
OPTIONS_ARR=()

# 1. Fluxdown 相关判断
# 探测并添加：下载文件（仅当 fluxdown CLI 可用时显示）
if command -v fluxdown >/dev/null 2>&1; then
    OPT_DOWNLOAD="下载文件 (fluxdown)"
    OPTIONS_ARR+=("$OPT_DOWNLOAD")
fi

# 如果没有探测到任何可用选项，直接退出以防止 fuzzel 报错
if [[ ${#OPTIONS_ARR[@]} -eq 0 ]]; then
    report_error "未探测到任何可用的维护指令。"
    exit 1
fi

# 调用 Fuzzel 显示菜单
SELECTED=$(printf "%s\n" "${OPTIONS_ARR[@]}" | fuzzel --dmenu \
    -p "脚本指令 > " \
    --placeholder "命令可手动运行" \
    --placeholder-color 80808099 || true)

# 如果用户未选择任何项直接退出
if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# 根据选择执行命令
# 所有的命令执行都使用探测所得的 CMD_/OPT_ 变量，实现了真正的逻辑解耦
case "$SELECTED" in
    "$OPT_DOWNLOAD")
        # 再次调用 fuzzel，使用 --lines 0 仅呈现输入框，用于获取下载地址
        URL=$(fuzzel --dmenu --lines 0 --prompt "输入下载地址 > " < /dev/null || true)

        # 用户取消或输入为空
        if [[ -z "$URL" ]]; then
            exit 0
        fi

        download_file "$URL"
        ;;
    *)
        report_error "未知的选项: $SELECTED"
        exit 1
        ;;
esac
