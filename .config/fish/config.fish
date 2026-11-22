if status is-interactive
# Commands to run in interactive sessions can go here
end
set -gx LC_CTYPE zh_CN.UTF-8
set -g fish_color_user 6ac967
set -gx PATH ~/Desktop/claude-code/bin $PATH

alias alas="cd ~/Desktop/Alas && uv run --no-sync gui.py"
alias qwen="cd ~/Downloads/Qwen3.5-4B-Q4 && GGML_CUDA_GRAPH_OPT=1 llama-server \
  -m Qwen3.5-4B-GSQ-Q2_K_XL.gguf \
  --mmproj mmproj-F16.gguf \
  --cache-type-k q8_0 --cache-type-v q5_0 \
  --host 127.0.0.1 --port 3456 \
  -ngl 99 \
  -c 16384 \
  --flash-attn on\
  -b 2048 \
  --jinja"
