#!/usr/bin/env bash
set -euo pipefail

# macOS 双击运行版本：
# 1) 把本文件拷贝到你的 training_site_deploy 目录
# 2) 右键 → 打开（或在终端里运行：chmod +x push_training_site.command）
# 3) 双击即可自动 add/commit/push

cd "$(dirname "$0")"
chmod +x "./push_training_site.sh" 2>/dev/null || true
./push_training_site.sh
