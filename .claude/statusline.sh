#!/bin/bash
# Claude Code status line. Reads session JSON on stdin and prints one line:
#   model · effort · branch · ctx [####------] 42% · 5h: 60% left (resets 14:30) · 7d: 80% left · cache cold
# Input fields: https://code.claude.com/docs/en/statusline#available-data

# The 7d segment shows its reset time once remaining usage drops below this.
# The 5h segment always shows it.
LOW_LIMIT_PCT=25

# Extract every field in one jq pass. @sh quotes each value so eval is safe;
# absent fields become empty strings.
eval "$(jq -r '
  def pct_used: if . == null then "" else round end;
  def pct_left: if . == null then "" else 100 - . | round end;
  def clock($fmt): if . == null then "" else strflocaltime($fmt) end;
  (.prompt_cache // {}) as $cache
  | @sh "model=\(.model.display_name // "")",
    @sh "effort=\(.effort.level // "")",
    @sh "cwd=\(.workspace.current_dir // "")",
    @sh "ctx_used=\(.context_window.used_percentage | pct_used)",
    @sh "five_left=\(.rate_limits.five_hour.used_percentage | pct_left)",
    @sh "five_resets=\(.rate_limits.five_hour.resets_at | clock("%H:%M"))",
    @sh "week_left=\(.rate_limits.seven_day.used_percentage | pct_left)",
    @sh "week_resets=\(.rate_limits.seven_day.resets_at | clock("%a %H:%M"))",
    @sh "cache_cold=\(if $cache.caching_observed
                        and (($cache.warm | not)
                             or ($cache.expires_at != null and now >= $cache.expires_at))
                      then "yes" else "" end)"
')"

branch=$([ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

# Ten-cell bar, one cell per 10% of context used.
context_bar() {
  local filled=$(( ($1 + 5) / 10 ))
  (( filled > 10 )) && filled=10
  printf '[%s%s]' "$(printf '%*s' "$filled" '' | tr ' ' '#')" \
                  "$(printf '%*s' $(( 10 - filled )) '' | tr ' ' '-')"
}

# "5h: 12% left", plus "(resets 14:30)" either always or only when running low.
limit_segment() {
  local label=$1 left=$2 resets=$3 show_resets=$4
  [ -n "$left" ] || return
  local segment="$label: ${left}% left"
  if [ -n "$resets" ] && { [ "$show_resets" = always ] || (( left < LOW_LIMIT_PCT )); }; then
    segment="$segment (resets $resets)"
  fi
  echo "$segment"
}

out=""
append() {
  [ -n "$1" ] || return
  [ -n "$out" ] && out="$out · "
  out="$out$1"
}

append "$model"
[ -n "$effort" ] && append "effort:$effort"
append "$branch"
[ -n "$ctx_used" ] && append "ctx $(context_bar "$ctx_used") ${ctx_used}%"
append "$(limit_segment 5h "$five_left" "$five_resets" always)"
append "$(limit_segment 7d "$week_left" "$week_resets" when-low)"
[ -n "$cache_cold" ] && append "cache cold"

echo "$out"
