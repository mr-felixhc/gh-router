
# ---------------------------------------------------------------------------
# resolve.sh — locate the real gh binary
# ---------------------------------------------------------------------------

# Print the directory containing this wrapper, so we never recurse into it.
ghr_self_dir() {
  case "$0" in
    */*) _self=$0 ;;
    *)   _self=$(command -v -- "$0" 2>/dev/null || printf '%s' "$0") ;;
  esac
  CDPATH= cd -- "$(dirname -- "$_self")" 2>/dev/null && pwd -P
}

# Print the first `gh` on PATH that is not this wrapper. Returns 1 if none.
ghr_find_real_gh() {
  _selfdir=$(ghr_self_dir)
  _oldIFS=$IFS
  IFS=:
  for _d in $PATH; do
    [ -n "$_d" ] || _d=.
    _cand="$_d/gh"
    [ -x "$_cand" ] || continue
    _cdir=$(CDPATH= cd -- "$_d" 2>/dev/null && pwd -P) || continue
    [ "$_cdir" = "$_selfdir" ] && continue
    IFS=$_oldIFS
    printf '%s\n' "$_cand"
    return 0
  done
  IFS=$_oldIFS
  return 1
}
