#!/bin/bash
# AI Video Transcriber 启动脚本
#
# 修复说明：原 start.py 只用 os.getenv 读环境变量，不会加载 .env，
# 导致 OPENAI_API_KEY 实际未生效（之前的摘要退化为空壳就是这个原因）。
# 这里先 source .env 再启动。

cd "$(dirname "$0")" || exit 1

if [ ! -f .env ]; then
  echo "❌ 缺少 .env 文件"
  echo "   请复制 .env.example 为 .env 并填入 OPENAI_API_KEY / OPENAI_BASE_URL"
  exit 1
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

if [ -z "$OPENAI_API_KEY" ]; then
  echo "⚠️  .env 里没有 OPENAI_API_KEY，AI 摘要与翻译功能将不可用"
fi

echo "🌐 启动 AI Video Transcriber → http://localhost:${PORT:-8000}"
exec ./venv/bin/python start.py --prod
