#!/bin/bash
# 延迟2秒执行，确保音频服务已完全就绪
sleep 2
# -i 表示加载输入降噪，-t 70 设置阈值为70%，适合大多数环境
noisetorch -i -t 70
