#!/usr/bin/env bash
# shorinclip - clipboard history manager using cliphist + fuzzel

# Show history, allow selection, copy selected item
# Filter with grep to strip cliphist stderr noise that leaks into stdout on decode errors
cliphist list 2>/dev/null | grep -P '^\d+\t' | fuzzel --dmenu --with-nth=2.. | cliphist decode | wl-copy
