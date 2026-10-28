# 本地修改说明

本仓库是 [wendy7756/AI-Video-Transcriber](https://github.com/wendy7756/AI-Video-Transcriber) 的衍生版本，遵循上游 Apache License 2.0。以下为相对上游的改动，按 Apache 2.0 第 4(b) 条声明。

## 改动清单

### 1. `backend/summarizer.py` — 增加 Gemini 兼容端点

上游只读 `OPENAI_API_KEY` / `OPENAI_BASE_URL`。本版增加 Gemini 作为回退：

```python
api_key  = os.getenv("OPENAI_API_KEY")  or os.getenv("GEMINI_API_KEY")
base_url = os.getenv("OPENAI_BASE_URL") or os.getenv("GEMINI_BASE_URL") \
           or "https://generativelanguage.googleapis.com/v1beta"
```

用途：OpenAI 官方端点不可用时，可切换到 Gemini 兼容接口。

### 2. 新增 `启动.sh` — 修复 `.env` 不生效

上游 `start.py` 只用 `os.getenv()` 读取配置，**从不加载 `.env` 文件**。结果是即便按 README 填好了 `.env`，`OPENAI_API_KEY` 也不会进入进程环境，摘要功能静默降级为一句"由于 OpenAI API 不可用，这是一个简化的摘要"。

`启动.sh` 在启动前先 `set -a; . ./.env` 把变量导出到环境，再调用 `start.py`：

```bash
./启动.sh
```

不改动上游任何代码，只在启动层兜住这个坑。

### 3. 未包含的内容

| 排除项 | 原因 |
|---|---|
| `venv/` | 虚拟环境，含绝对路径，换机必失效；用 `pip install -r requirements.txt` 重建 |
| `temp/` | 转录产物（音频、md），非程序 |
| `.env` | 含真实 API 凭据 |
| `backend/summarizer_patch.py` | 上游之外的一次性调试补丁，且内含硬编码的 API key，不公开 |

## 已知上游问题（未修改）

1. `.env` 不被加载（见上，已用启动脚本绕过）
2. `start.py` 默认 `--reload` 开发模式，生产环境需加 `--prod`
3. 长视频（>8 小时 / >256 MB）下载易中断
4. 摘要质量强依赖所配模型的上下文长度

## 安装

```bash
git clone <this-repo>
cd ai-video-transcriber
python3 -m venv venv
./venv/bin/pip install -r requirements.txt
cp .env.example .env   # 填入 OPENAI_API_KEY 与 OPENAI_BASE_URL
./启动.sh              # 或 ./venv/bin/python start.py --prod
```

打开 <http://localhost:8000>。

依赖 FFmpeg：`brew install ffmpeg`
