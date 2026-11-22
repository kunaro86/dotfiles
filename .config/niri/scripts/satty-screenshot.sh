#!/usr/bin/env bash

# 后台启动截图
niri msg action screenshot &

# 短暂等待，确保截图命令先注册事件
sleep 0.1

# 监听事件流，等待截图完成
log_output=$(niri msg event-stream | grep -m 1 --line-buffered "Screenshot captured")

# 提取文件路径（删除 "saved to " 之前的所有内容）
file_path="${log_output##*saved to }"

# 如果路径非空，用 satty 打开编辑
if [ -n "$file_path" ]; then
    satty --filename "$file_path"
fi
