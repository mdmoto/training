#!/usr/bin/env bash
set -euo pipefail

# 用法：
# 1) 把本脚本放到你的站点目录（例如 training_site_deploy）里
# 2) chmod +x push_training_site.sh
# 3) ./push_training_site.sh "your commit message"
#
# 默认 commit message：update site <YYYY-MM-DD HH:MM>

msg="${1:-}"
if [[ -z "${msg}" ]]; then
  msg="update site $(date '+%Y-%m-%d %H:%M')"
fi

if [[ ! -d ".git" ]]; then
  echo "ERROR: 当前目录不是 git 仓库（缺少 .git）。请先 cd 到 training_site_deploy 目录再运行。" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: 当前目录不是有效的 git 工作区。" >&2
  exit 1
fi

# 确保 main 分支
current_branch="$(git branch --show-current || true)"
if [[ "${current_branch}" != "main" ]]; then
  echo "切换到 main 分支..."
  git checkout -B main
fi

# 确保 origin 指向 mdmoto/training（SSH）
expected="git@github.com:mdmoto/training.git"
origin_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "${origin_url}" ]]; then
  echo "添加 origin: ${expected}"
  git remote add origin "${expected}"
elif [[ "${origin_url}" != "${expected}" ]]; then
  echo "更新 origin 为: ${expected}（原为：${origin_url}）"
  git remote set-url origin "${expected}"
fi

echo "检查 SSH 是否可用..."
if ! ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then
  echo "WARNING: SSH 认证检查未通过。你可以先手动运行：ssh -T git@github.com" >&2
fi

echo "添加变更..."
git add -A

if git diff --cached --quiet; then
  echo "没有可提交的变更（working tree clean）。"
  exit 0
fi

echo "提交：${msg}"
git commit -m "${msg}"

echo "推送到 origin/main ..."
git push -u origin main

echo "完成：已提交并推送。"
