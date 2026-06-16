
# ---------------------------------------------------------------------------
# rules.sh — expand fields and choose the most specific matching rule
# ---------------------------------------------------------------------------

# Expand a leading ~/ and the token $HOME inside a rule field.
ghr_expand() {
  _v=$1
  case "$_v" in
    "~")   _v=$HOME ;;
    "~/"*) _v=$HOME/${_v#"~/"} ;;
  esac
  case "$_v" in
    *'$HOME'*) _v=$(printf '%s' "$_v" | sed "s|\\\$HOME|$HOME|g") ;;
  esac
  printf '%s' "$_v"
}

# For $PWD, export the GH_CONFIG_DIR of the most specific (longest) matching
# pattern in $GHR_RULES. Order of rules in the file does not matter. Sets
# GHR_ROUTED to a human-readable summary for debug output.
ghr_route() {
  GHR_ROUTED="default"
  [ -f "$GHR_RULES" ] || return 0

  _best_len=-1
  _best_pat=
  _best_dir=
  while read -r _pat _dir _rest; do
    case "$_pat" in ''|\#*) continue ;; esac
    [ -n "${_dir:-}" ] || continue
    _pat=$(ghr_expand "$_pat")
    # shellcheck disable=SC2254  # $_pat is intentionally a glob pattern
    case "$PWD" in
      $_pat)
        _len=${#_pat}
        if [ "$_len" -gt "$_best_len" ]; then
          _best_len=$_len
          _best_pat=$_pat
          _best_dir=$_dir
        fi ;;
    esac
  done < "$GHR_RULES"

  [ "$_best_len" -ge 0 ] || return 0
  case "$_best_dir" in
    default|-)
      unset GH_CONFIG_DIR 2>/dev/null || true
      GHR_ROUTED="default ($_best_pat)" ;;
    *)
      GH_CONFIG_DIR=$(ghr_expand "$_best_dir")
      export GH_CONFIG_DIR
      GHR_ROUTED="$GH_CONFIG_DIR ($_best_pat)" ;;
  esac
}
