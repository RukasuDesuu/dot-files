#!/usr/bin/env bash
set -euo pipefail

LOG="/tmp/hypr-widget.log"
exec >>"$LOG" 2>&1
echo "---- $(date) ----"
echo "PATH=$PATH"

CLASS="pavucontrol"     # ajuste no waybar via flag --class se quiser
W=420
H=520
X_OFF=0
Y_OFF=28
ANCHOR="cursor"         # cursor|center|top-left|top-right|bottom-left|bottom-right
MODE="toggle"           # toggle|focus|spawn
FORCE_FLOAT=1           # força float apenas quando chamado aqui
MARGIN=10
NO_FOCUS=1              # <-- importante: evita focuswindow (evita warp do mouse)

CMD=()

usage() {
  echo "Usage: hypr-widget.sh [--class C] [--size WxH] [--offset X,Y] [--anchor A] [--mode M] [--no-float] [--focus] -- <cmd...>"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --class) CLASS="$2"; shift 2;;
    --size) IFS='x' read -r W H <<< "$2"; shift 2;;
    --offset) IFS=',' read -r X_OFF Y_OFF <<< "$2"; shift 2;;
    --anchor) ANCHOR="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --no-float) FORCE_FLOAT=0; shift 1;;
    --focus) NO_FOCUS=0; shift 1;;
    -h|--help) usage; exit 0;;
    --) shift; CMD=("$@"); break;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

if [[ ${#CMD[@]} -eq 0 ]]; then
  echo "Missing command. Use -- <command...>"
  usage
  exit 2
fi

command -v jq >/dev/null 2>&1 || { echo "jq is required."; exit 1; }

get_addr_by_class() {
  hyprctl -j clients | jq -r --arg c "$CLASS" '
    .[] | select((.class == $c) or (.initialClass == $c)) | .address
  ' | head -n1
}

get_pid_by_addr() {
  hyprctl -j clients | jq -r --arg a "$1" '.[] | select(.address==$a) | .pid' | head -n1
}

get_cursor_xy() {
  hyprctl cursorpos | tr -d ',' | awk '{print $1" "$2}'
}

# <- pega o monitor onde o cursor está (não o monitor focado!)
get_monitor_geom_for_cursor() {
  read -r CX CY <<< "$(get_cursor_xy)"
  hyprctl -j monitors | jq -r --argjson cx "$CX" --argjson cy "$CY" '
    .[] | select(
      ($cx >= .x) and ($cx < (.x + .width)) and
      ($cy >= .y) and ($cy < (.y + .height))
    ) | "\(.x) \(.y) \(.width) \(.height)"
  ' | head -n1
}

clamp() {
  local v="$1" lo="$2" hi="$3"
  if (( v < lo )); then echo "$lo"
  elif (( v > hi )); then echo "$hi"
  else echo "$v"
  fi
}

ADDR="$(get_addr_by_class || true)"

if [[ -n "${ADDR:-}" ]]; then
  if [[ "$MODE" == "toggle" ]]; then
    PID="$(get_pid_by_addr "$ADDR")"
    [[ -n "${PID:-}" && "$PID" != "null" ]] && kill "$PID" && exit 0
  fi
else
  [[ "$MODE" == "focus" ]] && exit 0
  "${CMD[@]}" & disown

  for _ in $(seq 1 100); do
    ADDR="$(get_addr_by_class || true)"
    [[ -n "${ADDR:-}" ]] && break
    sleep 0.02
  done
  [[ -z "${ADDR:-}" ]] && exit 1
fi

# NÃO FOCAR por padrão (evita warp do cursor) :contentReference[oaicite:1]{index=1}
if [[ "$NO_FOCUS" -eq 0 ]]; then
  hyprctl dispatch focuswindow "address:${ADDR}" >/dev/null || true
fi

# força float só nesse launch
if [[ "$FORCE_FLOAT" -eq 1 ]]; then
  IS_FLOAT="$(hyprctl -j clients | jq -r --arg a "$ADDR" '.[] | select(.address==$a) | .floating' | head -n1)"
  if [[ "${IS_FLOAT:-0}" != "true" ]]; then
    hyprctl dispatch togglefloating "address:${ADDR}" >/dev/null
  fi
fi

MON="$(get_monitor_geom_for_cursor)"
# fallback: se por algum motivo não achar monitor, usa o focado
if [[ -z "${MON:-}" ]]; then
  MON="$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | "\(.x) \(.y) \(.width) \(.height)"' | head -n1)"
fi

MON_X="$(awk '{print $1}' <<< "$MON")"
MON_Y="$(awk '{print $2}' <<< "$MON")"
MON_W="$(awk '{print $3}' <<< "$MON")"
MON_H="$(awk '{print $4}' <<< "$MON")"

case "$ANCHOR" in
  cursor)
    read -r CX CY <<< "$(get_cursor_xy)"
    BASE_X=$((CX - W/2))
    BASE_Y=$((CY))
    ;;
  center)
    BASE_X=$((MON_X + (MON_W - W)/2))
    BASE_Y=$((MON_Y + (MON_H - H)/2))
    ;;
  top-left)
    BASE_X=$((MON_X + MARGIN))
    BASE_Y=$((MON_Y + MARGIN))
    ;;
  top-right)
    BASE_X=$((MON_X + MON_W - W - MARGIN))
    BASE_Y=$((MON_Y + MARGIN))
    ;;
  bottom-left)
    BASE_X=$((MON_X + MARGIN))
    BASE_Y=$((MON_Y + MON_H - H - MARGIN))
    ;;
  bottom-right)
    BASE_X=$((MON_X + MON_W - W - MARGIN))
    BASE_Y=$((MON_Y + MON_H - H - MARGIN))
    ;;
  *)
    echo "Unknown anchor: $ANCHOR"; exit 2;;
esac

FINAL_X=$((BASE_X + X_OFF))
FINAL_Y=$((BASE_Y + Y_OFF))

MIN_X=$((MON_X + MARGIN))
MIN_Y=$((MON_Y + MARGIN))
MAX_X=$((MON_X + MON_W - W - MARGIN))
MAX_Y=$((MON_Y + MON_H - H - MARGIN))

FINAL_X="$(clamp "$FINAL_X" "$MIN_X" "$MAX_X")"
FINAL_Y="$(clamp "$FINAL_Y" "$MIN_Y" "$MAX_Y")"

# sem espaço depois da vírgula:
hyprctl dispatch resizewindowpixel "exact ${W} ${H},address:${ADDR}" >/dev/null
hyprctl dispatch movewindowpixel "exact ${FINAL_X} ${FINAL_Y},address:${ADDR}" >/dev/null
