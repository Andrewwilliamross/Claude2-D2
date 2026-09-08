#!/bin/bash

# Claude2-D2 v2 — context-aware droid notifications for Claude Code
# One script handles three hook events (dispatched on hook_event_name in the payload):
#   UserPromptSubmit -> records turn start time (silent)
#   Stop             -> "agent finished" notification, only for turns >= min_turn_seconds
#   Notification     -> permission requests always alert; idle_prompt is suppressed
#                       when it's just the 60s echo of a Stop we already announced
#
# Config:  ~/.claude/droid-config.json   (droids, plus optional min_turn_seconds /
#                                         idle_suppress_seconds)
# State:   ~/.claude/droid-state/        (per-session turn timestamps)
# Log:     ~/.claude/hook-debug.log      (one line per event, auto-rotated)

CLAUDE_DIR="$HOME/.claude"

# Hook payload arrives on stdin; capture it and hand it to python via env
CLAUDE_HOOK_PAYLOAD=$(cat)
export CLAUDE_HOOK_PAYLOAD

RESULT=$(python3 << 'PYTHON'
import json, os, random, re, subprocess, sys, time

claude_dir = os.path.expanduser("~/.claude")
state_dir = os.path.join(claude_dir, "droid-state")
sounds_base = os.path.join(claude_dir, "notification-sounds")
log_path = os.path.join(claude_dir, "hook-debug.log")

def log(line):
    try:
        if os.path.exists(log_path) and os.path.getsize(log_path) > 500_000:
            with open(log_path, "rb") as f:
                f.seek(-100_000, 2)
                tail = f.read()
            with open(log_path, "wb") as f:
                f.write(tail)
        with open(log_path, "a") as f:
            f.write(time.strftime("%Y-%m-%d %H:%M:%S ") + line + "\n")
    except Exception:
        pass

try:
    payload = json.loads(os.environ.get("CLAUDE_HOOK_PAYLOAD", "") or "{}")
except json.JSONDecodeError:
    payload = {}

event = payload.get("hook_event_name", "Notification")
session_id = payload.get("session_id", "unknown")
sid8 = session_id[:8]
cwd = payload.get("cwd", "") or os.environ.get("CLAUDE_PROJECT_DIR", "")
project = os.path.basename(cwd.rstrip("/")) or "unknown project"
message = payload.get("message", "")
ntype = payload.get("notification_type", "")

os.makedirs(state_dir, exist_ok=True)
now = time.time()

# Opportunistic cleanup of stale per-session state (> 2 days old)
try:
    for f in os.listdir(state_dir):
        p = os.path.join(state_dir, f)
        if now - os.path.getmtime(p) > 172800:
            os.remove(p)
except Exception:
    pass

def read_state(name):
    try:
        with open(os.path.join(state_dir, name)) as f:
            return f.read().strip()
    except Exception:
        return None

def write_state(name, value):
    try:
        with open(os.path.join(state_dir, name), "w") as f:
            f.write(str(value))
    except Exception:
        pass

# ---- turn-start bookkeeping (silent) ----
if event == "UserPromptSubmit":
    write_state(f"start-{session_id}", now)
    # User is back at this session: reset repeat-notification cooldowns
    for prefix in ("notif-idle-", "notif-permission-"):
        try:
            os.remove(os.path.join(state_dir, prefix + session_id))
        except OSError:
            pass
    log(f"UserPromptSubmit project={project} sid={sid8}")
    print("skip")
    sys.exit(0)

# ---- load droid config + per-project assignment (same scheme as v1) ----
try:
    with open(os.path.join(claude_dir, "droid-config.json")) as f:
        config = json.load(f)
except Exception:
    config = {"droids": {"r2d2": {"name": "R2-D2", "sounds_dir": "r2d2"}},
              "assignment_order": ["r2d2"], "default_droid": "r2d2"}

min_turn_seconds = config.get("min_turn_seconds", 30)
idle_suppress_seconds = config.get("idle_suppress_seconds", 150)

assignments_file = os.path.join(claude_dir, "droid-assignments.json")
try:
    with open(assignments_file) as f:
        assignments = json.load(f)
except Exception:
    assignments = {"assignments": {}, "next_assignment_index": 0}

project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "") or cwd
droid_id = assignments.get("assignments", {}).get(project_dir)
if not droid_id and project_dir:
    order = config.get("assignment_order", ["r2d2"])
    available = []
    for d in order:
        sdir = os.path.join(sounds_base, config["droids"].get(d, {}).get("sounds_dir", d))
        if os.path.isdir(sdir) and os.listdir(sdir):
            available.append(d)
    if not available:
        available = [config.get("default_droid", "r2d2")]
    idx = assignments.get("next_assignment_index", 0) % len(available)
    droid_id = available[idx]
    assignments["assignments"][project_dir] = droid_id
    assignments["next_assignment_index"] = (idx + 1) % len(available)
    try:
        with open(assignments_file, "w") as f:
            json.dump(assignments, f, indent=2)
    except Exception:
        pass
if not droid_id:
    droid_id = config.get("default_droid", "r2d2")

droid = config.get("droids", {}).get(droid_id, {})
droid_name = droid.get("name", droid_id)
sounds_dir = os.path.join(sounds_base, droid.get("sounds_dir", droid_id))

def pick_sound(prefixes):
    """Pick a sound whose filename starts with one of the prefixes; fall back to any."""
    try:
        files = sorted(f for f in os.listdir(sounds_dir)
                       if f.lower().endswith((".mp3", ".m4a")))
    except Exception:
        files = []
    if not files:
        return ""
    matches = [f for f in files if any(f.lower().startswith(p) for p in prefixes)]
    return os.path.join(sounds_dir, random.choice(matches or files))

group = f"claude-{session_id}"

# Which terminal? iTerm exposes window/tab/pane + session UUID in the environment.
# Note: the w/t indices are creation-time positions (they go stale if tabs are
# reordered), but the UUID lets click-to-focus find the real tab regardless.
loc, term_uuid = "", ""
m = re.match(r"w(\d+)t(\d+)p(\d+):([0-9A-Fa-f]{8}(?:-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12})$",
             os.environ.get("ITERM_SESSION_ID", ""))
if m:
    loc = f"Win {int(m.group(1)) + 1} · Tab {int(m.group(2)) + 1}"
    term_uuid = m.group(4)

# Banners post via the droid app bundles: those identities are the ones with
# notification permission (terminal-notifier's own identity has style "None",
# so sender-less banners silently don't display on this machine).
senders = {"r2d2": "com.claude.claude2d2", "bd1": "com.claude.bd1", "ig11": "com.claude.ig11"}
sender = senders.get(droid_id, "com.claude.claude2d2")

# Per-AI color identity (macOS won't tint banner backgrounds, so: chip emoji on
# the model line + solid color swatch via -contentImage on the banner's right)
AGENTS = {
    "Claude Code": ("🟠", "agent-claude.png"),
    "Codex":       ("⚪", "agent-codex.png"),
    "Grok":        ("⚫", "agent-grok.png"),
    "Prime-Agent": ("🟣", "agent-prime.png"),
}

def agent_and_model():
    """(agent, pretty model) from the last assistant message in the transcript."""
    try:
        with open(payload.get("transcript_path", ""), "rb") as f:
            f.seek(0, 2)
            f.seek(max(0, f.tell() - 65536))
            chunk = f.read().decode("utf-8", "ignore")
        ids = [i for i in re.findall(r'"model"\s*:\s*"([^"]+)"', chunk)
               if i and not i.startswith("<")]
        if not ids:
            return "Claude Code", ""
        mid = ids[-1].lower()
        if mid.startswith("claude"):
            core = re.sub(r"-\d{8}$", "", mid[len("claude-"):])
            parts = core.split("-")
            nums = [p for p in parts[1:] if p.isdigit()]
            return "Claude Code", f"{parts[0].capitalize()} {'.'.join(nums)}".strip()
        if "codex" in mid or mid.startswith(("gpt", "o1", "o3", "o4")):
            return "Codex", ids[-1]
        if "grok" in mid:
            return "Grok", ids[-1]
        if "prime" in mid:
            return "Prime-Agent", ids[-1]
        return "Claude Code", ids[-1]
    except Exception:
        return "Claude Code", ""

agent, model = agent_and_model()
chip, swatch_file = AGENTS.get(agent, AGENTS["Claude Code"])
swatch = os.path.join(claude_dir, "icons", swatch_file)

def tab_title():
    """Chat title = this session's iTerm tab name, looked up by UUID.
    Hard 3s timeout: a stalled iTerm must never block the notification."""
    if not term_uuid:
        return ""
    script = f'''tell application "iTerm2"
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if id of s contains "{term_uuid}" then return name of s
            end repeat
        end repeat
    end repeat
end tell'''
    try:
        out = subprocess.run(["osascript", "-e", script], capture_output=True,
                             text=True, timeout=3).stdout.strip()
        out = re.sub(r"^[^0-9A-Za-z]+", "", out)
        return re.sub(r" \([^)]*\)$", "", out).strip()
    except Exception:
        return ""

def emit(status):
    """Banner: title = project, line 2 = chat title (fallback Win/Tab).
    Status text (permission ask etc.) takes the message slot when present;
    otherwise the chat title rides there since -message is mandatory."""
    tt = tab_title() or loc
    subtitle, message = (tt, status) if status else ("", tt or project)
    print("notify")
    print(project)
    print(subtitle)
    print(message)
    print(sound)
    print(group)
    print(sender)
    print(swatch)

# ---- Stop: agent finished its turn ----
if event == "Stop":
    start = read_state(f"start-{session_id}")
    duration = (now - float(start)) if start else None
    if duration is not None and duration < min_turn_seconds:
        write_state(f"stop-{session_id}", f"{now} silent")
        log(f"Stop project={project} sid={sid8} dur={duration:.0f}s -> silent (< {min_turn_seconds}s)")
        print("skip")
        sys.exit(0)
    write_state(f"stop-{session_id}", f"{now} notified")
    sound = pick_sound(["acknowledged", "excited", "happy", "chat"])
    log(f"Stop project={project} sid={sid8} dur={f'{int(duration)}s' if duration else 'unknown'} loc={loc or '?'} -> notify droid={droid_id}")
    emit(f"{agent} - {model}" if model else agent)
    sys.exit(0)

# ---- Notification: classify by type AND message text ----
# Claude Code versions differ: some send idle reminders as notification_type
# "idle_prompt", newer ones send message "Waiting for your next prompt" (or an
# empty message) with no type at all — so type alone can't be trusted. Sessions
# also re-send the same reminder every few minutes, hence the repeat cooldowns.
msg_l = message.lower()
if "permission" in ntype or "permission" in msg_l or "approval" in msg_l:
    nclass = "permission"
elif ntype == "idle_prompt" or "waiting" in msg_l or (not message and not ntype):
    nclass = "idle"
else:
    nclass = "alert"

def repeat_suppressed(cooldown):
    """True if this class already notified for this session within cooldown."""
    last = read_state(f"notif-{nclass}-{session_id}")
    return last is not None and now - float(last) < cooldown

if nclass == "idle":
    # Any recent turn-end means the user was just interacting with this session —
    # the 60s "waiting for input" echo is noise there, announced Stop or not.
    # Idle only alerts for sessions with no recent turn activity (stuck on a
    # question mid-turn, or a forgotten session).
    stop_state = read_state(f"stop-{session_id}")
    if stop_state:
        stop_ts = float(stop_state.split()[0])
        if now - stop_ts < idle_suppress_seconds:
            log(f"Notification/idle project={project} sid={sid8} -> suppressed (turn ended {int(now - stop_ts)}s ago)")
            print("skip")
            sys.exit(0)
    if repeat_suppressed(config.get("idle_repeat_cooldown_seconds", 600)):
        log(f"Notification/idle project={project} sid={sid8} -> suppressed (repeat within cooldown)")
        print("skip")
        sys.exit(0)
    write_state(f"notif-idle-{session_id}", now)
    sound = pick_sound(["chat", "neutral"])
    log(f"Notification/idle project={project} sid={sid8} loc={loc or '?'} -> notify droid={droid_id}")
    emit("⏳ waiting for input")
    sys.exit(0)

if nclass == "permission":
    if repeat_suppressed(config.get("permission_repeat_cooldown_seconds", 300)):
        log(f"Notification/permission project={project} sid={sid8} -> suppressed (repeat within cooldown)")
        print("skip")
        sys.exit(0)
    write_state(f"notif-permission-{session_id}", now)
    sound = pick_sound(["question", "worried"])
    log(f"Notification/permission project={project} sid={sid8} loc={loc or '?'} -> notify droid={droid_id} msg={message!r}")
    emit(f"🔐 {message or 'needs permission'}")
    sys.exit(0)

# Anything else always alerts, with the real message
sound = pick_sound(["question", "worried"])
log(f"Notification/{ntype or 'other'} project={project} sid={sid8} loc={loc or '?'} -> notify droid={droid_id} msg={message!r}")
emit(f"❗ {message or 'needs attention'}")
PYTHON
)

ACTION=$(echo "$RESULT" | sed -n '1p')
[ "$ACTION" != "notify" ] && exit 0

TITLE=$(echo "$RESULT" | sed -n '2p')
SUBTITLE=$(echo "$RESULT" | sed -n '3p')
MESSAGE=$(echo "$RESULT" | sed -n '4p')
SOUND=$(echo "$RESULT" | sed -n '5p')
GROUP=$(echo "$RESULT" | sed -n '6p')
SENDER=$(echo "$RESULT" | sed -n '7p')
SWATCH=$(echo "$RESULT" | sed -n '8p')

# DROID_DRY_RUN=1 runs the full pipeline but skips the real sound/banner (for testing)
if [ -n "$DROID_DRY_RUN" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') DRY-RUN: would notify: $TITLE | $SUBTITLE | $MESSAGE" >> "$HOME/.claude/hook-debug.log"
    echo "DRY-RUN: $TITLE | $SUBTITLE | $MESSAGE | sound=$(basename "$SOUND" 2>/dev/null) | sender=$SENDER"
    exit 0
fi

if [ -n "$SOUND" ] && [ -f "$SOUND" ]; then
    afplay "$SOUND" &
fi

TN=$(command -v terminal-notifier || echo /opt/homebrew/bin/terminal-notifier)
if [ -x "$TN" ]; then
    ARGS=(-title "$TITLE" -message "$MESSAGE" -group "$GROUP" -sender "$SENDER")
    [ -n "$SUBTITLE" ] && ARGS+=(-subtitle "$SUBTITLE")
    [ -n "$SWATCH" ] && [ -f "$SWATCH" ] && ARGS+=(-contentImage "$SWATCH")
    # Foreground on purpose: a backgrounded post can be reaped before delivery,
    # and this way the exit code lands in the trace
    "$TN" "${ARGS[@]}" >/dev/null 2>&1
    BRANCH="terminal-notifier exit=$?"
else
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
    BRANCH="osascript-fallback exit=$?"
fi

# Delivery trace: proves the shell half actually dispatched (vs dying upstream)
echo "$(date '+%Y-%m-%d %H:%M:%S') shell: dispatched via $BRANCH '$TITLE | $SUBTITLE | $MESSAGE' sound=$(basename "$SOUND" 2>/dev/null)" >> "$HOME/.claude/hook-debug.log"

exit 0
