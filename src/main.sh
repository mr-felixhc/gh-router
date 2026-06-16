
# ---------------------------------------------------------------------------
# main.sh — orchestrate and hand off to the real gh
# ---------------------------------------------------------------------------

case "${1:-}" in
  --gh-router-version)
    printf 'gh-router %s\n' "$GHR_VERSION"
    exit 0 ;;
esac

ghr_real=$(ghr_find_real_gh) || {
  echo "gh-router: could not find the real 'gh' on PATH (is GitHub CLI installed?)" >&2
  exit 127
}

ghr_route

[ -n "${GH_ROUTER_DEBUG:-}" ] && printf 'gh-router: %s -> %s\n' "$PWD" "$GHR_ROUTED" >&2

exec "$ghr_real" "$@"
